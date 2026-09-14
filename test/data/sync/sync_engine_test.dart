import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/data/sync/sync_bootstrap.dart';
import 'package:repooor/data/sync/sync_engine.dart';
import 'package:repooor/data/sync/sync_operation.dart';
import 'package:repooor/data/sync/sync_pusher.dart';
import 'package:repooor/data/sync/sync_queue_local_ds.dart';
import 'package:repooor/data/sync/sync_status.dart';
import 'package:repooor/domain/entities/auth/app_user.dart';
import 'package:repooor/domain/repositories/auth_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'sync_test_db.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSyncPusher extends Mock implements SyncPusher {}

class _MockSyncBootstrap extends Mock implements SyncBootstrap {}

class _MockConnectivity extends Mock implements Connectivity {}

const _user = AppUser(
  id: 'user-1',
  email: 'mikael@exemplo.com',
  name: 'Mikael',
);

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late SyncQueueLocalDs queue;
  late _MockAuthRepository auth;
  late _MockSyncPusher pusher;
  late _MockSyncBootstrap bootstrap;
  late SyncEngine engine;

  setUp(() async {
    db = await openSyncTestDatabase();
    queue = SyncQueueLocalDs(openDatabase: () async => db);
    auth = _MockAuthRepository();
    pusher = _MockSyncPusher();
    bootstrap = _MockSyncBootstrap();
    engine = SyncEngine(
      auth: auth,
      pusher: pusher,
      bootstrap: bootstrap,
      queue: queue,
      connectivity: _MockConnectivity(),
    );
    when(() => bootstrap.ensure(any())).thenAnswer((_) async => 0);
    when(() => auth.currentUser()).thenAnswer((_) async => _user);
  });

  tearDown(() async {
    engine.dispose();
    await db.close();
  });

  Future<void> enqueue(String id) {
    return queue.enqueue(
      SyncOperation(
        id: id,
        entity: 'products',
        entityId: 'prod-$id',
        op: SyncOp.upsert,
        createdAt: 100,
      ),
    );
  }

  test('should not push while nobody is signed in', () async {
    when(() => auth.currentUser()).thenAnswer((_) async => null);

    await engine.syncNow();

    expect(engine.status.phase, SyncPhase.idle);
    verifyNever(() => pusher.push(userId: any(named: 'userId')));
  });

  test('should bootstrap before the first push', () async {
    when(
      () => pusher.push(userId: any(named: 'userId')),
    ).thenAnswer((_) async => const SyncPushResult(sent: 3));

    await engine.syncNow();

    verify(() => bootstrap.ensure('user-1')).called(1);
    verify(() => pusher.push(userId: 'user-1')).called(1);
    expect(engine.status.phase, SyncPhase.idle);
  });

  test(
    'should report waiting for connection when the push is cut off',
    () async {
      await enqueue('op-1');
      when(() => pusher.push(userId: any(named: 'userId'))).thenAnswer(
        (_) async => const SyncPushResult(interrupted: true, error: 'sem rede'),
      );

      await engine.syncNow();

      expect(engine.status.phase, SyncPhase.waitingConnection);
      expect(engine.status.pending, 1);
      expect(engine.status.message, 'sem rede');
    },
  );

  test('should report an error when the server rejects an operation', () async {
    await enqueue('op-1');
    await queue.giveUp('op-1', '400 invalido');
    when(
      () => pusher.push(userId: any(named: 'userId')),
    ).thenAnswer((_) async => const SyncPushResult(rejected: 1));

    await engine.syncNow();

    expect(engine.status.phase, SyncPhase.error);
    expect(engine.status.rejected, 1);
  });

  test('should not start a second push while one is running', () async {
    var calls = 0;
    when(() => pusher.push(userId: any(named: 'userId'))).thenAnswer((_) async {
      calls++;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return const SyncPushResult(sent: 1);
    });

    await Future.wait([engine.syncNow(), engine.syncNow(), engine.syncNow()]);

    expect(calls, 1);
  });

  test('should survive an unexpected failure without throwing', () async {
    when(
      () => pusher.push(userId: any(named: 'userId')),
    ).thenThrow(StateError('boom'));

    await engine.syncNow();

    expect(engine.status.phase, SyncPhase.error);
  });

  test('should publish the status to listeners', () async {
    when(
      () => pusher.push(userId: any(named: 'userId')),
    ).thenAnswer((_) async => const SyncPushResult(sent: 1));

    final seen = <SyncPhase>[];
    final subscription = engine.statusStream.listen((s) => seen.add(s.phase));
    await Future<void>.delayed(Duration.zero);
    await engine.syncNow();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(seen, contains(SyncPhase.syncing));
    expect(seen.last, SyncPhase.idle);
  });
}
