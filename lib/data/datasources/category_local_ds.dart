import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import 'database_helper.dart';

class CategoryLocalDs {
  static const _table = 'categories';

  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<CategoryModel>> getAll() async {
    final db = await _db;
    final maps = await db.query(_table, orderBy: 'name ASC');
    return maps.map(CategoryModel.fromMap).toList();
  }

  Future<CategoryModel?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  Future<void> insert(CategoryModel model) async {
    final db = await _db;
    await db.insert(_table, model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(CategoryModel model) async {
    final db = await _db;
    await db.update(_table, model.toMap(), where: 'id = ?', whereArgs: [model.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertBatch(List<CategoryModel> models) async {
    final db = await _db;
    final batch = db.batch();
    for (final model in models) {
      batch.insert(_table, model.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }
}
