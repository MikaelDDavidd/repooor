import 'package:sqflite/sqflite.dart';
import '../datasources/database_helper.dart';
import 'sync_operation.dart';

class SyncQueueLocalDs {
  SyncQueueLocalDs({Future<Database> Function()? openDatabase})
    : _openDatabase = openDatabase;

  static const table = 'sync_queue';
  static const maxAttempts = 5;

  final Future<Database> Function()? _openDatabase;

  Future<Database> get _db =>
      _openDatabase?.call() ?? DatabaseHelper.instance.database;

  Future<void> enqueue(SyncOperation operation) async {
    final db = await _db;
    await db.insert(
      table,
      operation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> enqueueAll(List<SyncOperation> operations) async {
    if (operations.isEmpty) return;
    final db = await _db;
    final batch = db.batch();
    for (final operation in operations) {
      batch.insert(
        table,
        operation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // created_at sozinho empata quando duas operações caem no mesmo
  // milissegundo; o rowid desempata mantendo a ordem de inserção.
  Future<List<SyncOperation>> pending({int limit = 50}) async {
    final db = await _db;
    final maps = await db.query(
      table,
      where: 'attempts < ?',
      whereArgs: [maxAttempts],
      orderBy: 'created_at ASC, rowid ASC',
      limit: limit,
    );
    return maps.map(SyncOperation.fromMap).toList();
  }

  Future<void> remove(String id) async {
    final db = await _db;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // Falha temporária (rede, servidor fora, sessão expirada) não gasta
  // tentativa: uma semana sem internet não pode apagar o trabalho offline.
  Future<void> registerError(String id, String error) async {
    final db = await _db;
    await db.update(
      table,
      {'last_error': error},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> giveUp(String id, String error) async {
    final db = await _db;
    await db.update(
      table,
      {'attempts': maxAttempts, 'last_error': error},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countPending() => _count('attempts < $maxAttempts');

  Future<int> countFailed() => _count('attempts >= $maxAttempts');

  Future<int> _count(String where) async {
    final db = await _db;
    final rows = await db.rawQuery('SELECT COUNT(*) FROM $table WHERE $where');
    return (rows.first.values.first as num).toInt();
  }

  Future<bool> hasOperationFor(String entity, String entityId) async {
    final db = await _db;
    final rows = await db.query(
      table,
      where: 'entity = ? AND entity_id = ?',
      whereArgs: [entity, entityId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
