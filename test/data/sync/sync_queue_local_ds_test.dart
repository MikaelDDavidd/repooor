import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/sync/sync_operation.dart';
import 'package:repooor/data/sync/sync_queue_local_ds.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'sync_test_db.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late SyncQueueLocalDs queue;

  setUp(() async {
    db = await openSyncTestDatabase();
    queue = SyncQueueLocalDs(openDatabase: () async => db);
  });

  tearDown(() => db.close());

  SyncOperation operation(
    String id, {
    String entity = 'products',
    String entityId = 'prod-1',
    SyncOp op = SyncOp.upsert,
    int createdAt = 1750000000000,
  }) {
    return SyncOperation(
      id: id,
      entity: entity,
      entityId: entityId,
      op: op,
      createdAt: createdAt,
    );
  }

  test('should return an enqueued operation intact', () async {
    await queue.enqueue(
      operation('op-1', entity: 'categories', op: SyncOp.delete),
    );

    final pending = await queue.pending();

    expect(pending, hasLength(1));
    expect(pending.single.id, 'op-1');
    expect(pending.single.entity, 'categories');
    expect(pending.single.op, SyncOp.delete);
    expect(pending.single.attempts, 0);
    expect(pending.single.lastError, isNull);
  });

  test('should keep the order the operations were created in', () async {
    await queue.enqueue(operation('op-1', createdAt: 300));
    await queue.enqueue(operation('op-2', createdAt: 100));
    await queue.enqueue(operation('op-3', createdAt: 200));

    final pending = await queue.pending();

    expect(pending.map((o) => o.id), ['op-2', 'op-3', 'op-1']);
  });

  test('should fall back to insertion order on the same millisecond', () async {
    await queue.enqueueAll([
      operation('op-1', createdAt: 100),
      operation('op-2', createdAt: 100),
      operation('op-3', createdAt: 100),
    ]);

    final pending = await queue.pending();

    expect(pending.map((o) => o.id), ['op-1', 'op-2', 'op-3']);
  });

  test('should drop an operation once it is removed', () async {
    await queue.enqueue(operation('op-1'));

    await queue.remove('op-1');

    expect(await queue.pending(), isEmpty);
    expect(await queue.countPending(), 0);
  });

  test('should record the error without spending an attempt', () async {
    await queue.enqueue(operation('op-1'));

    await queue.registerError('op-1', 'sem rede');

    final pending = await queue.pending();
    expect(pending.single.attempts, 0);
    expect(pending.single.lastError, 'sem rede');
  });

  test('should take a rejected operation out of the pending list', () async {
    await queue.enqueue(operation('op-1'));

    await queue.giveUp('op-1', '400 general_argument_invalid');

    expect(await queue.pending(), isEmpty);
    expect(await queue.countPending(), 0);
    expect(await queue.countFailed(), 1);
  });

  test('should respect the batch limit', () async {
    await queue.enqueueAll([
      for (var i = 0; i < 10; i++) operation('op-$i', createdAt: 100 + i),
    ]);

    final pending = await queue.pending(limit: 4);

    expect(pending, hasLength(4));
    expect(pending.first.id, 'op-0');
  });

  test('should tell whether an entity already has an operation', () async {
    await queue.enqueue(operation('op-1', entityId: 'prod-9'));

    expect(await queue.hasOperationFor('products', 'prod-9'), isTrue);
    expect(await queue.hasOperationFor('products', 'prod-outro'), isFalse);
  });

  test('should hold fifty offline operations in order', () async {
    await queue.enqueueAll([
      for (var i = 0; i < 50; i++)
        operation('op-$i', entityId: 'prod-$i', createdAt: 1000 + i),
    ]);

    expect(await queue.countPending(), 50);

    final pending = await queue.pending(limit: 50);
    expect(pending.map((o) => o.entityId).take(3), [
      'prod-0',
      'prod-1',
      'prod-2',
    ]);
    expect(pending.last.entityId, 'prod-49');
  });
}
