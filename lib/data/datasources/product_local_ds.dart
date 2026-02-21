import 'package:sqflite/sqflite.dart';
import '../models/product_model.dart';
import 'database_helper.dart';

class ProductLocalDs {
  static const _table = 'products';

  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<ProductModel>> getAll() async {
    final db = await _db;
    final maps = await db.query(_table, orderBy: 'name ASC');
    return maps.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> getByCategory(String categoryId) async {
    final db = await _db;
    final maps = await db.query(
      _table,
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    return maps.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> search(String query) async {
    final db = await _db;
    final maps = await db.query(
      _table,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map(ProductModel.fromMap).toList();
  }

  Future<ProductModel?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  Future<void> insert(ProductModel model) async {
    final db = await _db;
    await db.insert(_table, model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(ProductModel model) async {
    final db = await _db;
    await db.update(_table, model.toMap(), where: 'id = ?', whereArgs: [model.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
