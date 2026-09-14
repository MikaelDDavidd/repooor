import 'package:sqflite/sqflite.dart';
import '../datasources/database_helper.dart';

class SyncStateLocalDs {
  SyncStateLocalDs({Future<Database> Function()? openDatabase})
    : _openDatabase = openDatabase;

  static const table = 'sync_state';

  final Future<Database> Function()? _openDatabase;

  Future<Database> get _db =>
      _openDatabase?.call() ?? DatabaseHelper.instance.database;

  Future<int?> markerOf(String key) async {
    final db = await _db;
    final rows = await db.query(
      table,
      where: 'entity = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return (rows.first['last_pulled_at'] as num?)?.toInt();
  }

  Future<void> setMarker(String key, int value) async {
    final db = await _db;
    await db.insert(table, {
      'entity': key,
      'last_pulled_at': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
