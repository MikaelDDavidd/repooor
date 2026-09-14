import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/datasources/database_migrations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> createV2Schema(Database db) async {
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
}

Future<void> createV3Schema(Database db) async {
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
      planned_unit_price REAL
    )
  ''');
}

Future<Set<String>> columnsOf(Database db, String table) async {
  final info = await db.rawQuery('PRAGMA table_info($table)');
  return info.map((row) => row['name'] as String).toSet();
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('adds the picked column when upgrading from v3', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: 3,
        onCreate: (db, _) async {
          await createV3Schema(db);
          await db.insert('purchases', {
            'id': 'antiga',
            'date': '2026-05-01T00:00:00.000',
            'type': 'main',
            'status': 'completed',
          });
          await db.insert('purchase_items', {
            'id': 'item-1',
            'purchase_id': 'antiga',
            'product_id': 'arroz',
            'quantity': 2.0,
            'unit_price': 28.9,
          });
        },
      ),
    );
    await DatabaseMigrations.onUpgrade(db, 3, 4);
    addTearDown(db.close);

    final row = (await db.query('purchase_items')).single;

    expect(await columnsOf(db, 'purchase_items'), contains('picked'));
    expect(row['picked'], 0);
    expect(row['unit_price'], 28.9);
  });

  test('upgrades straight from v2 to v4', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: 2,
        onCreate: (db, _) async => createV2Schema(db),
      ),
    );
    await DatabaseMigrations.onUpgrade(db, 2, 4);
    addTearDown(db.close);

    expect(
      await columnsOf(db, 'purchase_items'),
      containsAll(['planned_quantity', 'planned_unit_price', 'picked']),
    );
  });

  test('creates a fresh database with the new columns', () async {
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

    expect(await columnsOf(db, 'purchases'), contains('status'));
    expect(
      await columnsOf(db, 'purchase_items'),
      containsAll([
        'planned_quantity',
        'planned_unit_price',
        'unit_price',
        'picked',
      ]),
    );
  });

  test('upgrades a v2 database adding the new columns', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: 2,
        onCreate: (db, _) async => createV2Schema(db),
      ),
    );
    await DatabaseMigrations.onUpgrade(db, 2, 3);
    addTearDown(db.close);

    expect(await columnsOf(db, 'purchases'), contains('status'));
    expect(
      await columnsOf(db, 'purchase_items'),
      containsAll(['planned_quantity', 'planned_unit_price']),
    );
  });

  test('marks existing purchases as completed so they keep working', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: 2,
        onCreate: (db, _) async {
          await createV2Schema(db);
          await db.insert('purchases', {
            'id': 'antiga',
            'date': '2026-05-01T00:00:00.000',
            'type': 'main',
          });
        },
      ),
    );
    await DatabaseMigrations.onUpgrade(db, 2, 3);
    addTearDown(db.close);

    final rows = await db.query('purchases');

    expect(rows.single['status'], 'completed');
    expect(rows.single['id'], 'antiga');
  });

  test('keeps existing purchase item data intact', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: 2,
        onCreate: (db, _) async {
          await createV2Schema(db);
          await db.insert('purchases', {
            'id': 'antiga',
            'date': '2026-05-01T00:00:00.000',
            'type': 'main',
          });
          await db.insert('purchase_items', {
            'id': 'item-1',
            'purchase_id': 'antiga',
            'product_id': 'arroz',
            'quantity': 2.0,
            'unit_price': 28.9,
          });
        },
      ),
    );
    await DatabaseMigrations.onUpgrade(db, 2, 3);
    addTearDown(db.close);

    final row = (await db.query('purchase_items')).single;

    expect(row['quantity'], 2.0);
    expect(row['unit_price'], 28.9);
    expect(row['planned_quantity'], isNull);
    expect(row['planned_unit_price'], isNull);
  });

  test('upgrades a v1 database through every step', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: 1,
        onCreate: (db, _) async {
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
              quantity REAL NOT NULL
            )
          ''');
        },
      ),
    );
    await DatabaseMigrations.onUpgrade(db, 1, 4);
    addTearDown(db.close);

    expect(
      await columnsOf(db, 'purchase_items'),
      containsAll([
        'unit_price',
        'planned_quantity',
        'planned_unit_price',
        'picked',
      ]),
    );
    expect(await columnsOf(db, 'purchases'), contains('status'));
  });

  test('accepts planned purchases after the upgrade', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: 2,
        onCreate: (db, _) async => createV2Schema(db),
      ),
    );
    await DatabaseMigrations.onUpgrade(db, 2, 3);
    addTearDown(db.close);

    await db.insert('purchases', {
      'id': 'plano',
      'date': '2026-07-24T00:00:00.000',
      'type': 'main',
      'status': 'planned',
    });
    await db.insert('purchase_items', {
      'id': 'item-plano',
      'purchase_id': 'plano',
      'product_id': 'arroz',
      'quantity': 2.0,
      'unit_price': 28.9,
      'planned_quantity': 2.0,
      'planned_unit_price': 28.9,
    });

    final purchase = (await db.query(
      'purchases',
      where: 'id = ?',
      whereArgs: ['plano'],
    )).single;
    final item = (await db.query('purchase_items')).single;

    expect(purchase['status'], 'planned');
    expect(item['planned_unit_price'], 28.9);
  });
}
