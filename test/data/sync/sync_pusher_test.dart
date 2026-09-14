import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/data/sync/sync_operation.dart';
import 'package:repooor/data/sync/sync_pusher.dart';
import 'package:repooor/data/sync/sync_queue_local_ds.dart';
import 'package:repooor/data/sync/sync_row_local_ds.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'sync_test_db.dart';

class _MockTablesDB extends Mock implements TablesDB {}

appwrite.Row buildRow() {
  return appwrite.Row(
    $id: 'prod-1',
    $sequence: '1',
    $tableId: 'products',
    $databaseId: 'repooor',
    $createdAt: '2026-07-27T00:00:00.000+00:00',
    $updatedAt: '2026-07-27T00:00:00.000+00:00',
    $permissions: const [],
    data: const {},
  );
}

AppwriteException networkError() =>
    AppwriteException('ClientException with SocketException: host lookup');

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late SyncQueueLocalDs queue;
  late SyncRowLocalDs rows;
  late _MockTablesDB tablesDb;
  late SyncPusher pusher;

  setUp(() async {
    db = await openSyncTestDatabase();
    queue = SyncQueueLocalDs(openDatabase: () async => db);
    rows = SyncRowLocalDs(openDatabase: () async => db);
    tablesDb = _MockTablesDB();
    pusher = SyncPusher(tablesDb, queue, rows);
  });

  tearDown(() => db.close());

  Future<void> enqueueUpsert(
    String id,
    String entityId, {
    int createdAt = 100,
  }) {
    return queue.enqueue(
      SyncOperation(
        id: id,
        entity: 'products',
        entityId: entityId,
        op: SyncOp.upsert,
        createdAt: createdAt,
      ),
    );
  }

  void stubUpsertOk() {
    when(
      () => tablesDb.upsertRow(
        databaseId: any(named: 'databaseId'),
        tableId: any(named: 'tableId'),
        rowId: any(named: 'rowId'),
        data: any(named: 'data'),
        permissions: any(named: 'permissions'),
      ),
    ).thenAnswer((_) async => buildRow());
  }

  test('should send the current row and clear the queue', () async {
    await seedProduct(db, 'prod-1', name: 'Arroz', updatedAt: 1750000000001);
    await enqueueUpsert('op-1', 'prod-1');
    stubUpsertOk();

    final result = await pusher.push(userId: 'user-1');

    expect(result.sent, 1);
    expect(result.interrupted, isFalse);
    expect(await queue.countPending(), 0);

    final captured = verify(
      () => tablesDb.upsertRow(
        databaseId: any(named: 'databaseId'),
        tableId: captureAny(named: 'tableId'),
        rowId: captureAny(named: 'rowId'),
        data: captureAny(named: 'data'),
        permissions: captureAny(named: 'permissions'),
      ),
    ).captured;

    expect(captured[0], 'products');
    expect(captured[1], 'prod-1');
    final data = captured[2] as Map;
    expect(data['name'], 'Arroz');
    expect(data['categoryId'], 'cat-1');
    expect(data['userId'], 'user-1');
    expect(data['updatedAt'], 1750000000001);
    expect(
      captured[3],
      containsAll(<String>['read("user:user-1")', 'update("user:user-1")']),
    );
  });

  test(
    'should reuse the local id so a repeated push does not duplicate',
    () async {
      await seedProduct(db, 'prod-1');
      await enqueueUpsert('op-1', 'prod-1');
      await enqueueUpsert('op-2', 'prod-1', createdAt: 200);
      stubUpsertOk();

      await pusher.push(userId: 'user-1');

      final rowIds = verify(
        () => tablesDb.upsertRow(
          databaseId: any(named: 'databaseId'),
          tableId: any(named: 'tableId'),
          rowId: captureAny(named: 'rowId'),
          data: any(named: 'data'),
          permissions: any(named: 'permissions'),
        ),
      ).captured;

      expect(rowIds, ['prod-1', 'prod-1']);
      expect(await queue.countPending(), 0);
    },
  );

  test('should keep the operation queued when the network fails', () async {
    await seedProduct(db, 'prod-1');
    await enqueueUpsert('op-1', 'prod-1');
    when(
      () => tablesDb.upsertRow(
        databaseId: any(named: 'databaseId'),
        tableId: any(named: 'tableId'),
        rowId: any(named: 'rowId'),
        data: any(named: 'data'),
        permissions: any(named: 'permissions'),
      ),
    ).thenThrow(networkError());

    final result = await pusher.push(userId: 'user-1');

    expect(result.interrupted, isTrue);
    expect(result.sent, 0);
    expect(await queue.countPending(), 1);
    expect((await queue.pending()).single.attempts, 0);
    expect((await queue.pending()).single.lastError, isNotNull);
  });

  test('should not spend attempts across repeated outages', () async {
    await seedProduct(db, 'prod-1');
    await enqueueUpsert('op-1', 'prod-1');
    when(
      () => tablesDb.upsertRow(
        databaseId: any(named: 'databaseId'),
        tableId: any(named: 'tableId'),
        rowId: any(named: 'rowId'),
        data: any(named: 'data'),
        permissions: any(named: 'permissions'),
      ),
    ).thenThrow(networkError());

    for (var i = 0; i < 8; i++) {
      await pusher.push(userId: 'user-1');
    }

    expect(await queue.countPending(), 1);
    expect(await queue.countFailed(), 0);
  });

  test('should stop retrying a rejected operation', () async {
    await seedProduct(db, 'prod-1');
    await enqueueUpsert('op-1', 'prod-1');
    when(
      () => tablesDb.upsertRow(
        databaseId: any(named: 'databaseId'),
        tableId: any(named: 'tableId'),
        rowId: any(named: 'rowId'),
        data: any(named: 'data'),
        permissions: any(named: 'permissions'),
      ),
    ).thenThrow(
      AppwriteException('Invalid document', 400, 'general_argument_invalid'),
    );

    final result = await pusher.push(userId: 'user-1');

    expect(result.rejected, 1);
    expect(result.interrupted, isFalse);
    expect(await queue.countPending(), 0);
    expect(await queue.countFailed(), 1);
  });

  test(
    'should stop the push and keep everything when the session expires',
    () async {
      await seedProduct(db, 'prod-1');
      await enqueueUpsert('op-1', 'prod-1');
      when(
        () => tablesDb.upsertRow(
          databaseId: any(named: 'databaseId'),
          tableId: any(named: 'tableId'),
          rowId: any(named: 'rowId'),
          data: any(named: 'data'),
          permissions: any(named: 'permissions'),
        ),
      ).thenThrow(AppwriteException('Unauthorized', 401, 'user_unauthorized'));

      final result = await pusher.push(userId: 'user-1');

      expect(result.interrupted, isTrue);
      expect(await queue.countPending(), 1);
      expect(await queue.countFailed(), 0);
    },
  );

  test('should skip an upsert whose row no longer exists locally', () async {
    await enqueueUpsert('op-1', 'prod-sumiu');

    final result = await pusher.push(userId: 'user-1');

    expect(result.sent, 1);
    expect(await queue.countPending(), 0);
    verifyNever(
      () => tablesDb.upsertRow(
        databaseId: any(named: 'databaseId'),
        tableId: any(named: 'tableId'),
        rowId: any(named: 'rowId'),
        data: any(named: 'data'),
        permissions: any(named: 'permissions'),
      ),
    );
  });

  test('should mark the remote row as deleted on a delete operation', () async {
    await queue.enqueue(
      const SyncOperation(
        id: 'op-1',
        entity: 'products',
        entityId: 'prod-1',
        op: SyncOp.delete,
        createdAt: 100,
      ),
    );
    when(
      () => tablesDb.updateRow(
        databaseId: any(named: 'databaseId'),
        tableId: any(named: 'tableId'),
        rowId: any(named: 'rowId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => buildRow());

    final result = await pusher.push(userId: 'user-1');

    expect(result.sent, 1);
    final data =
        verify(
              () => tablesDb.updateRow(
                databaseId: any(named: 'databaseId'),
                tableId: any(named: 'tableId'),
                rowId: 'prod-1',
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map;
    expect(data['deletedAt'], isA<int>());
    expect(data['updatedAt'], isA<int>());
  });

  test('should treat a missing remote row as an already done delete', () async {
    await queue.enqueue(
      const SyncOperation(
        id: 'op-1',
        entity: 'products',
        entityId: 'prod-1',
        op: SyncOp.delete,
        createdAt: 100,
      ),
    );
    when(
      () => tablesDb.updateRow(
        databaseId: any(named: 'databaseId'),
        tableId: any(named: 'tableId'),
        rowId: any(named: 'rowId'),
        data: any(named: 'data'),
      ),
    ).thenThrow(AppwriteException('Not found', 404, 'row_not_found'));

    final result = await pusher.push(userId: 'user-1');

    expect(result.sent, 1);
    expect(await queue.countPending(), 0);
  });

  test('should push fifty offline operations in order', () async {
    for (var i = 0; i < 50; i++) {
      await seedProduct(db, 'prod-$i', name: 'Produto $i');
      await enqueueUpsert('op-$i', 'prod-$i', createdAt: 1000 + i);
    }
    stubUpsertOk();

    final result = await pusher.push(userId: 'user-1');

    expect(result.sent, 50);
    expect(await queue.countPending(), 0);

    final rowIds = verify(
      () => tablesDb.upsertRow(
        databaseId: any(named: 'databaseId'),
        tableId: any(named: 'tableId'),
        rowId: captureAny(named: 'rowId'),
        data: any(named: 'data'),
        permissions: any(named: 'permissions'),
      ),
    ).captured;

    expect(rowIds.first, 'prod-0');
    expect(rowIds.last, 'prod-49');
    expect(rowIds, hasLength(50));
  });
}
