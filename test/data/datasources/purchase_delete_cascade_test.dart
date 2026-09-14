import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/datasources/database_migrations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> addPurchase(Database db, String id) => db.insert('purchases', {
  'id': id,
  'date': '2026-07-25T10:00:00.000',
  'type': 'main',
  'status': 'completed',
});

Future<void> addItem(Database db, String id, String purchaseId) =>
    db.insert('purchase_items', {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': 'arroz',
      'quantity': 1.0,
      'unit_price': 5.0,
    });

Future<int> orphanCount(Database db) async {
  final rows = await db.rawQuery(
    'SELECT COUNT(*) c FROM purchase_items pi '
    'LEFT JOIN purchases p ON p.id = pi.purchase_id WHERE p.id IS NULL',
  );
  return (rows.first['c'] as num).toInt();
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('o cascade do schema não age sozinho no sqflite', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: DatabaseMigrations.currentVersion,
        onCreate: DatabaseMigrations.onCreate,
      ),
    );
    addTearDown(db.close);
    await addPurchase(db, 'c1');
    await addItem(db, 'i1', 'c1');

    // apagar só a compra, como o código antigo fazia
    await db.delete('purchases', where: 'id = ?', whereArgs: ['c1']);

    expect(
      await orphanCount(db),
      1,
      reason: 'confirma por que o delete precisa apagar os itens à mão',
    );
  });

  test('a migração v6 limpa os órfãos deixados pelo bug', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: 5,
        onCreate: (db, _) async {
          await DatabaseMigrations.onCreate(db, 5);
          await addPurchase(db, 'viva');
          await addItem(db, 'i-viva', 'viva');
          await addItem(db, 'i-fantasma-1', 'compra-que-nao-existe');
          await addItem(db, 'i-fantasma-2', 'outra-que-nao-existe');
        },
      ),
    );
    addTearDown(db.close);

    expect(await orphanCount(db), 2);

    await DatabaseMigrations.onUpgrade(db, 5, 6);

    expect(await orphanCount(db), 0);
    final survivors = await db.query('purchase_items');
    expect(survivors, hasLength(1));
    expect(survivors.single['id'], 'i-viva');
  });

  test('não apaga item de compra existente', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: 5,
        onCreate: (db, _) async {
          await DatabaseMigrations.onCreate(db, 5);
          await addPurchase(db, 'c1');
          await addItem(db, 'i1', 'c1');
          await addItem(db, 'i2', 'c1');
        },
      ),
    );
    addTearDown(db.close);

    await DatabaseMigrations.onUpgrade(db, 5, 6);

    final rows = await db.query('purchase_items');
    expect(rows, hasLength(2));
  });
}
