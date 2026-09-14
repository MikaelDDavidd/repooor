import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/datasources/database_migrations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> createV6Schema(Database db) async {
  await db.execute('''
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      icon INTEGER NOT NULL,
      color INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE products (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      category_id TEXT NOT NULL,
      unit TEXT NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE pantry_items (
      id TEXT PRIMARY KEY,
      product_id TEXT NOT NULL UNIQUE,
      current_quantity REAL NOT NULL DEFAULT 0,
      ideal_quantity REAL NOT NULL DEFAULT 0
    )
  ''');
  await db.execute('''
    CREATE TABLE purchases (
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      type TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'completed'
    )
  ''');
  await db.execute('''
    CREATE TABLE purchase_items (
      id TEXT PRIMARY KEY,
      purchase_id TEXT NOT NULL,
      product_id TEXT NOT NULL,
      quantity REAL NOT NULL,
      unit_price REAL,
      planned_quantity REAL,
      planned_unit_price REAL,
      picked INTEGER NOT NULL DEFAULT 0
    )
  ''');
}

Future<Set<String>> columnsOf(Database db, String table) async {
  final info = await db.rawQuery('PRAGMA table_info($table)');
  return info.map((row) => row['name'] as String).toSet();
}

Future<int> firstInt(Database db, String sql) async {
  final rows = await db.rawQuery(sql);
  return rows.first.values.first as int;
}

Future<int> countOf(Database db, String table) {
  return firstInt(db, 'SELECT COUNT(*) FROM $table');
}

Future<bool> tableExists(Database db, String table) async {
  final rows = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
    [table],
  );
  return rows.isNotEmpty;
}

// Reproduz o volume real do aparelho do Mikael em 2026-07-26.
Future<void> seedRealisticData(Database db) async {
  for (var i = 0; i < 10; i++) {
    await db.insert('categories', {
      'id': 'cat-$i',
      'name': 'Categoria $i',
      'icon': 100 + i,
      'color': 200 + i,
    });
  }
  for (var i = 0; i < 85; i++) {
    await db.insert('products', {
      'id': 'prod-$i',
      'name': 'Produto $i',
      'category_id': 'cat-${i % 10}',
      'unit': 'un',
    });
  }
  for (var i = 0; i < 44; i++) {
    await db.insert('pantry_items', {
      'id': 'pantry-$i',
      'product_id': 'prod-$i',
      'current_quantity': i.toDouble(),
      'ideal_quantity': (i + 2).toDouble(),
    });
  }
  for (var i = 0; i < 4; i++) {
    await db.insert('purchases', {
      'id': 'purchase-$i',
      'date': '2026-0${i + 1}-01T00:00:00.000',
      'type': 'main',
      'status': 'completed',
    });
  }
  for (var i = 0; i < 98; i++) {
    await db.insert('purchase_items', {
      'id': 'item-$i',
      'purchase_id': 'purchase-${i % 4}',
      'product_id': 'prod-${i % 85}',
      'quantity': 2.0,
      'unit_price': 9.9,
      'picked': 1,
    });
  }
}

Future<Database> openV6({Future<void> Function(Database db)? seed}) {
  return databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      singleInstance: false,
      version: 6,
      onCreate: (db, _) async {
        await createV6Schema(db);
        if (seed != null) await seed(db);
      },
    ),
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('adds the sync columns to every synced table', () async {
    final db = await openV6();
    addTearDown(db.close);

    await DatabaseMigrations.onUpgrade(db, 6, 7);

    for (final table in DatabaseMigrations.syncedTables) {
      expect(
        await columnsOf(db, table),
        containsAll(['updated_at', 'deleted_at']),
        reason: 'tabela $table',
      );
    }
  });

  test('creates the sync queue and sync state tables', () async {
    final db = await openV6();
    addTearDown(db.close);

    await DatabaseMigrations.onUpgrade(db, 6, 7);

    expect(await tableExists(db, 'sync_queue'), isTrue);
    expect(await tableExists(db, 'sync_state'), isTrue);
    expect(
      await columnsOf(db, 'sync_queue'),
      containsAll([
        'id',
        'entity',
        'entity_id',
        'op',
        'payload',
        'attempts',
        'last_error',
        'created_at',
      ]),
    );
    expect(
      await columnsOf(db, 'sync_state'),
      containsAll(['entity', 'last_pulled_at']),
    );
  });

  test(
    'keeps every row of a realistic database and backfills updated_at',
    () async {
      final db = await openV6(seed: seedRealisticData);
      addTearDown(db.close);

      await DatabaseMigrations.onUpgrade(db, 6, 7);

      expect(await countOf(db, 'categories'), 10);
      expect(await countOf(db, 'products'), 85);
      expect(await countOf(db, 'pantry_items'), 44);
      expect(await countOf(db, 'purchases'), 4);
      expect(await countOf(db, 'purchase_items'), 98);

      for (final table in DatabaseMigrations.syncedTables) {
        final pending = await firstInt(
          db,
          'SELECT COUNT(*) FROM $table WHERE updated_at IS NULL',
        );
        expect(pending, 0, reason: 'tabela $table com updated_at nulo');
      }
    },
  );

  test('keeps the existing column values untouched', () async {
    final db = await openV6(seed: seedRealisticData);
    addTearDown(db.close);

    await DatabaseMigrations.onUpgrade(db, 6, 7);

    final item = (await db.query(
      'purchase_items',
      where: 'id = ?',
      whereArgs: ['item-7'],
    )).single;

    expect(item['quantity'], 2.0);
    expect(item['unit_price'], 9.9);
    expect(item['picked'], 1);
    expect(item['purchase_id'], 'purchase-3');
    expect(item['deleted_at'], isNull);
    expect(item['updated_at'], isA<int>());
  });

  test(
    'leaves deleted_at null so nothing looks deleted after the upgrade',
    () async {
      final db = await openV6(seed: seedRealisticData);
      addTearDown(db.close);

      await DatabaseMigrations.onUpgrade(db, 6, 7);

      for (final table in DatabaseMigrations.syncedTables) {
        final deleted = await firstInt(
          db,
          'SELECT COUNT(*) FROM $table WHERE deleted_at IS NOT NULL',
        );
        expect(deleted, 0, reason: 'tabela $table');
      }
    },
  );

  test('can be applied twice without failing', () async {
    final db = await openV6(seed: seedRealisticData);
    addTearDown(db.close);

    await DatabaseMigrations.onUpgrade(db, 6, 7);
    await DatabaseMigrations.onUpgrade(db, 6, 7);

    expect(await countOf(db, 'products'), 85);
    expect(await columnsOf(db, 'products'), containsAll(['updated_at']));
  });

  test('upgrades straight from v2 to v7', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: 2,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE categories (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              icon INTEGER NOT NULL,
              color INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE products (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              category_id TEXT NOT NULL,
              unit TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE pantry_items (
              id TEXT PRIMARY KEY,
              product_id TEXT NOT NULL UNIQUE,
              current_quantity REAL NOT NULL DEFAULT 0,
              ideal_quantity REAL NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE TABLE purchases (
              id TEXT PRIMARY KEY,
              date TEXT NOT NULL,
              type TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE purchase_items (
              id TEXT PRIMARY KEY,
              purchase_id TEXT NOT NULL,
              product_id TEXT NOT NULL,
              quantity REAL NOT NULL,
              unit_price REAL
            )
          ''');
        },
      ),
    );
    addTearDown(db.close);

    await DatabaseMigrations.onUpgrade(db, 2, 7);

    expect(
      await columnsOf(db, 'purchase_items'),
      containsAll(['picked', 'planned_quantity', 'updated_at', 'deleted_at']),
    );
    expect(await tableExists(db, 'sync_queue'), isTrue);
  });

  test('a fresh install is already on the v7 schema', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: DatabaseMigrations.currentVersion,
        onCreate: DatabaseMigrations.onCreate,
        onUpgrade: DatabaseMigrations.onUpgrade,
      ),
    );
    addTearDown(db.close);

    for (final table in DatabaseMigrations.syncedTables) {
      expect(
        await columnsOf(db, table),
        containsAll(['updated_at', 'deleted_at']),
        reason: 'tabela $table',
      );
    }
    expect(await tableExists(db, 'sync_queue'), isTrue);
    expect(await tableExists(db, 'sync_state'), isTrue);
  });

  test('the sync queue accepts and returns an operation', () async {
    final db = await openV6();
    addTearDown(db.close);
    await DatabaseMigrations.onUpgrade(db, 6, 7);

    await db.insert('sync_queue', {
      'id': 'op-1',
      'entity': 'products',
      'entity_id': 'prod-1',
      'op': 'upsert',
      'payload': '{"name":"Arroz"}',
      'created_at': 1750000000000,
    });

    final row = (await db.query('sync_queue')).single;

    expect(row['entity'], 'products');
    expect(row['op'], 'upsert');
    expect(row['attempts'], 0);
    expect(row['last_error'], isNull);
    expect(row['payload'], '{"name":"Arroz"}');
  });

  test('sync state keeps one cursor per entity', () async {
    final db = await openV6();
    addTearDown(db.close);
    await DatabaseMigrations.onUpgrade(db, 6, 7);

    await db.insert('sync_state', {
      'entity': 'products',
      'last_pulled_at': 1750000000000,
    });
    await db.insert('sync_state', {
      'entity': 'products',
      'last_pulled_at': 1760000000000,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    final rows = await db.query('sync_state');

    expect(rows, hasLength(1));
    expect(rows.single['last_pulled_at'], 1760000000000);
  });
}
