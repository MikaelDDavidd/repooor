import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/sync/sync_bootstrap.dart';
import 'package:repooor/data/sync/sync_queue_local_ds.dart';
import 'package:repooor/data/sync/sync_recorder.dart';
import 'package:repooor/data/sync/sync_row_local_ds.dart';
import 'package:repooor/data/sync/sync_state_local_ds.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'sync_test_db.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late SyncQueueLocalDs queue;
  late SyncBootstrap bootstrap;

  setUp(() async {
    db = await openSyncTestDatabase();
    queue = SyncQueueLocalDs(openDatabase: () async => db);
    bootstrap = SyncBootstrap(
      SyncRowLocalDs(openDatabase: () async => db),
      SyncRecorder(queue),
      SyncStateLocalDs(openDatabase: () async => db),
    );
  });

  tearDown(() => db.close());

  // Espelha o aparelho do Mikael em 2026-07-26.
  Future<void> seedRealisticData() async {
    for (var i = 0; i < 10; i++) {
      await seedCategory(db, 'cat-$i');
    }
    for (var i = 0; i < 85; i++) {
      await seedProduct(db, 'prod-$i', categoryId: 'cat-${i % 10}');
    }
    for (var i = 0; i < 44; i++) {
      await db.insert('pantry_items', {
        'id': 'pantry-$i',
        'product_id': 'prod-$i',
        'current_quantity': 1.0,
        'ideal_quantity': 2.0,
        'updated_at': 1750000000000,
      });
    }
    for (var i = 0; i < 4; i++) {
      await db.insert('purchases', {
        'id': 'purchase-$i',
        'date': '2026-0${i + 1}-01T00:00:00.000',
        'type': 'main',
        'status': 'completed',
        'updated_at': 1750000000000,
      });
    }
    for (var i = 0; i < 98; i++) {
      await db.insert('purchase_items', {
        'id': 'item-$i',
        'purchase_id': 'purchase-${i % 4}',
        'product_id': 'prod-${i % 85}',
        'quantity': 1.0,
        'picked': 1,
        'updated_at': 1750000000000,
      });
    }
  }

  test('should queue everything already on the device', () async {
    await seedRealisticData();

    final enqueued = await bootstrap.ensure('user-1');

    expect(enqueued, 10 + 85 + 44 + 4 + 98);
    expect(await queue.countPending(), 241);
  });

  test('should queue categories before the products that use them', () async {
    await seedCategory(db, 'cat-1');
    await seedProduct(db, 'prod-1', categoryId: 'cat-1');

    await bootstrap.ensure('user-1');

    final pending = await queue.pending();
    expect(pending.map((o) => o.entity), ['categories', 'products']);
  });

  test('should not queue the same data twice', () async {
    await seedRealisticData();

    await bootstrap.ensure('user-1');
    final second = await bootstrap.ensure('user-1');

    expect(second, 0);
    expect(await queue.countPending(), 241);
  });

  test('should run again for a different account', () async {
    await seedProduct(db, 'prod-1');

    await bootstrap.ensure('user-1');
    final other = await bootstrap.ensure('user-2');

    expect(other, 1);
  });

  test('should do nothing on an empty device', () async {
    expect(await bootstrap.ensure('user-1'), 0);
    expect(await queue.countPending(), 0);
  });
}
