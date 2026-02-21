import 'package:sqflite/sqflite.dart';
import '../models/purchase_model.dart';
import '../models/purchase_item_model.dart';
import 'database_helper.dart';

class PurchaseLocalDs {
  static const _tablePurchases = 'purchases';
  static const _tableItems = 'purchase_items';

  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<PurchaseModel>> getAll() async {
    final db = await _db;
    final maps = await db.query(_tablePurchases, orderBy: 'date DESC');
    return maps.map(PurchaseModel.fromMap).toList();
  }

  Future<PurchaseModel?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(_tablePurchases, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return PurchaseModel.fromMap(maps.first);
  }

  Future<List<PurchaseModel>> getByMonth(int year, int month) async {
    final db = await _db;
    final start = DateTime(year, month).toIso8601String();
    final end = DateTime(year, month + 1).toIso8601String();
    final maps = await db.query(
      _tablePurchases,
      where: 'date >= ? AND date < ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return maps.map(PurchaseModel.fromMap).toList();
  }

  Future<void> insert(PurchaseModel model) async {
    final db = await _db;
    await db.insert(_tablePurchases, model.toMap());
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(_tablePurchases, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PurchaseItemModel>> getItemsByPurchaseId(String purchaseId) async {
    final db = await _db;
    final maps = await db.query(
      _tableItems,
      where: 'purchase_id = ?',
      whereArgs: [purchaseId],
    );
    return maps.map(PurchaseItemModel.fromMap).toList();
  }

  Future<void> insertItem(PurchaseItemModel model) async {
    final db = await _db;
    await db.insert(_tableItems, model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteItem(String itemId) async {
    final db = await _db;
    await db.delete(_tableItems, where: 'id = ?', whereArgs: [itemId]);
  }

  Future<void> updateItem(PurchaseItemModel model) async {
    final db = await _db;
    await db.update(_tableItems, model.toMap(), where: 'id = ?', whereArgs: [model.id]);
  }
}
