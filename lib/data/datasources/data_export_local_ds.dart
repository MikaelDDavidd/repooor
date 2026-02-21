import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class DataExportLocalDs {
  static const _tables = [
    'categories',
    'products',
    'pantry_items',
    'purchases',
    'purchase_items',
  ];

  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<Map<String, dynamic>> exportAll() async {
    final db = await _db;
    final result = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
    };

    for (final table in _tables) {
      result[table] = await db.query(table);
    }

    return result;
  }

  Future<void> importAll(Map<String, dynamic> data) async {
    final db = await _db;
    await db.transaction((txn) async {
      for (final table in _tables.reversed) {
        await txn.delete(table);
      }

      for (final table in _tables) {
        final rows = data[table] as List<dynamic>?;
        if (rows == null) continue;

        final batch = txn.batch();
        for (final row in rows) {
          batch.insert(table, Map<String, dynamic>.from(row as Map));
        }
        await batch.commit(noResult: true);
      }
    });
  }

  Future<void> clearAll() async {
    final db = await _db;
    await db.transaction((txn) async {
      for (final table in _tables.reversed) {
        await txn.delete(table);
      }
    });
  }
}
