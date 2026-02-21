import 'package:sqflite/sqflite.dart';
import '../models/pantry_item_model.dart';
import 'database_helper.dart';

class PantryLocalDs {
  static const _table = 'pantry_items';

  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<PantryItemModel>> getAll() async {
    final db = await _db;
    final maps = await db.query(_table);
    return maps.map(PantryItemModel.fromMap).toList();
  }

  Future<PantryItemModel?> getByProductId(String productId) async {
    final db = await _db;
    final maps = await db.query(
      _table,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    if (maps.isEmpty) return null;
    return PantryItemModel.fromMap(maps.first);
  }

  Future<void> insert(PantryItemModel model) async {
    final db = await _db;
    await db.insert(_table, model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateQuantity(String id, double currentQuantity) async {
    final db = await _db;
    await db.update(
      _table,
      {'current_quantity': currentQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateIdealQuantity(String id, double idealQuantity) async {
    final db = await _db;
    await db.update(
      _table,
      {'ideal_quantity': idealQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PantryItemModel>> getLowStock() async {
    final db = await _db;
    final maps = await db.rawQuery(
      'SELECT * FROM $_table WHERE ideal_quantity > 0 AND current_quantity < ideal_quantity * 0.5',
    );
    return maps.map(PantryItemModel.fromMap).toList();
  }
}
