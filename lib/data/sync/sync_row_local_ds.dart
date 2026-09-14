import 'package:sqflite/sqflite.dart';
import '../datasources/database_helper.dart';
import '../datasources/database_migrations.dart';

class SyncRowLocalDs {
  SyncRowLocalDs({Future<Database> Function()? openDatabase})
    : _openDatabase = openDatabase;

  final Future<Database> Function()? _openDatabase;

  Future<Database> get _db =>
      _openDatabase?.call() ?? DatabaseHelper.instance.database;

  Future<Map<String, dynamic>?> findById(String entity, String id) async {
    if (!DatabaseMigrations.syncedTables.contains(entity)) return null;
    final db = await _db;
    final rows = await db.query(
      entity,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<String>> idsOf(String entity) async {
    if (!DatabaseMigrations.syncedTables.contains(entity)) return const [];
    final db = await _db;
    final rows = await db.query(entity, columns: ['id']);
    return rows.map((row) => row['id'] as String).toList();
  }
}
