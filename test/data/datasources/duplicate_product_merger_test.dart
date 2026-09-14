import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/datasources/database_migrations.dart';
import 'package:repooor/data/datasources/duplicate_product_merger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> freshDb() async {
  return databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      singleInstance: false,
      version: DatabaseMigrations.currentVersion,
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
    ),
  );
}

Future<void> addProduct(Database db, String id, String name) => db.insert(
  'products',
  {'id': id, 'name': name, 'category_id': 'c1', 'unit': 'un'},
);

Future<void> addPantry(
  Database db,
  String id,
  String productId, {
  double current = 1,
  double ideal = 2,
}) => db.insert('pantry_items', {
  'id': id,
  'product_id': productId,
  'current_quantity': current,
  'ideal_quantity': ideal,
});

Future<void> addPurchaseItem(Database db, String id, String productId) =>
    db.insert('purchase_items', {
      'id': id,
      'purchase_id': 'compra-1',
      'product_id': productId,
      'quantity': 1.0,
      'unit_price': 5.0,
    });

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;

  setUp(() async {
    db = await freshDb();
    await db.insert('purchases', {
      'id': 'compra-1',
      'date': '2026-07-25T10:00:00.000',
      'type': 'main',
      'status': 'completed',
    });
  });

  tearDown(() => db.close());

  Future<int> countOf(String table) async {
    final rows = await db.rawQuery('SELECT COUNT(*) c FROM $table');
    return (rows.first['c'] as num).toInt();
  }

  test('funde produtos com o mesmo nome', () async {
    await addProduct(db, 'a', 'Arroz');
    await addProduct(db, 'b', 'Arroz');

    final merged = await DuplicateProductMerger.run(db);

    expect(merged, 1);
    expect(await countOf('products'), 1);
  });

  test('ignora caixa e acento ao agrupar', () async {
    await addProduct(db, 'a', 'Água Sanitária');
    await addProduct(db, 'b', 'agua sanitaria');

    await DuplicateProductMerger.run(db);

    expect(await countOf('products'), 1);
  });

  test('reaponta o histórico de compra e não perde item', () async {
    await addProduct(db, 'a', 'Arroz');
    await addProduct(db, 'b', 'Arroz');
    await addPurchaseItem(db, 'i1', 'a');
    await addPurchaseItem(db, 'i2', 'b');
    await addPurchaseItem(db, 'i3', 'b');

    await DuplicateProductMerger.run(db);

    expect(await countOf('purchase_items'), 3);
    final survivor = (await db.query('products')).single['id'];
    final rows = await db.query(
      'purchase_items',
      where: 'product_id = ?',
      whereArgs: [survivor],
    );
    expect(rows, hasLength(3));
  });

  test('mantém o produto que está na despensa', () async {
    await addProduct(db, 'sem-despensa', 'Feijão');
    await addProduct(db, 'com-despensa', 'Feijão');
    await addPantry(db, 'pi-1', 'com-despensa');
    await addPurchaseItem(db, 'i1', 'sem-despensa');
    await addPurchaseItem(db, 'i2', 'sem-despensa');

    await DuplicateProductMerger.run(db);

    expect((await db.query('products')).single['id'], 'com-despensa');
  });

  test('soma as quantidades quando os dois estão na despensa', () async {
    await addProduct(db, 'a', 'Óleo');
    await addProduct(db, 'b', 'Óleo');
    await addPantry(db, 'pi-a', 'a', current: 2, ideal: 4);
    await addPantry(db, 'pi-b', 'b', current: 3, ideal: 6);

    await DuplicateProductMerger.run(db);

    final pantry = (await db.query('pantry_items')).single;
    expect(pantry['current_quantity'], 5.0);
    expect(pantry['ideal_quantity'], 6.0);
    expect(await countOf('pantry_items'), 1);
  });

  test('leva a despensa do perdedor quando o vencedor não tem', () async {
    await addProduct(db, 'vencedor', 'Sal');
    await addProduct(db, 'perdedor', 'Sal');
    await addPurchaseItem(db, 'i1', 'vencedor');
    await addPantry(db, 'pi-perdedor', 'perdedor', current: 7, ideal: 9);

    await DuplicateProductMerger.run(db);

    final pantry = (await db.query('pantry_items')).single;
    expect(pantry['current_quantity'], 7.0);
    expect(await countOf('products'), 1);
  });

  test('não mexe em produto sem duplicata', () async {
    await addProduct(db, 'a', 'Arroz');
    await addProduct(db, 'b', 'Feijão');

    final merged = await DuplicateProductMerger.run(db);

    expect(merged, 0);
    expect(await countOf('products'), 2);
  });

  test('funde grupo de três', () async {
    await addProduct(db, 'a', 'Macarrão');
    await addProduct(db, 'b', 'macarrao');
    await addProduct(db, 'c', 'MACARRÃO');

    final merged = await DuplicateProductMerger.run(db);

    expect(merged, 2);
    expect(await countOf('products'), 1);
  });

  test('não deixa item de compra órfão', () async {
    await addProduct(db, 'a', 'Arroz');
    await addProduct(db, 'b', 'Arroz');
    await addPurchaseItem(db, 'i1', 'b');

    await DuplicateProductMerger.run(db);

    final orphans = await db.rawQuery(
      'SELECT COUNT(*) c FROM purchase_items pi '
      'LEFT JOIN products p ON p.id = pi.product_id WHERE p.id IS NULL',
    );
    expect((orphans.first['c'] as num).toInt(), 0);
  });

  test('roda junto com a migração para a v5', () async {
    final legacy = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        version: 4,
        onCreate: (db, _) async {
          await DatabaseMigrations.onCreate(db, 4);
          await addProduct(db, 'a', 'Arroz');
          await addProduct(db, 'b', 'Arroz');
        },
      ),
    );
    await DatabaseMigrations.onUpgrade(legacy, 4, 5);

    final rows = await legacy.rawQuery('SELECT COUNT(*) c FROM products');
    expect((rows.first['c'] as num).toInt(), 1);
    await legacy.close();
  });
}
