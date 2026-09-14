import 'package:appwrite/appwrite.dart';

import '../../core/config/appwrite_config.dart';
import 'sync_operation.dart';
import 'sync_payload.dart';
import 'sync_queue_local_ds.dart';
import 'sync_row_local_ds.dart';

class SyncPushResult {
  const SyncPushResult({
    this.sent = 0,
    this.rejected = 0,
    this.interrupted = false,
    this.error,
  });

  final int sent;
  final int rejected;
  final bool interrupted;
  final String? error;
}

class SyncPusher {
  SyncPusher(this._tablesDb, this._queue, this._rows, {this.batchSize = 50});

  final TablesDB _tablesDb;
  final SyncQueueLocalDs _queue;
  final SyncRowLocalDs _rows;
  final int batchSize;

  Future<SyncPushResult> push({required String userId}) async {
    var sent = 0;
    var rejected = 0;

    while (true) {
      final batch = await _queue.pending(limit: batchSize);
      if (batch.isEmpty) break;

      var handled = 0;
      for (final operation in batch) {
        try {
          await _send(operation, userId);
          await _queue.remove(operation.id);
          sent++;
          handled++;
        } on AppwriteException catch (e) {
          final reason = _describe(e);
          if (_isPermanent(e)) {
            await _queue.giveUp(operation.id, reason);
            rejected++;
            handled++;
            continue;
          }
          await _queue.registerError(operation.id, reason);
          return SyncPushResult(
            sent: sent,
            rejected: rejected,
            interrupted: true,
            error: reason,
          );
        }
      }
      if (handled == 0) break;
    }

    return SyncPushResult(sent: sent, rejected: rejected);
  }

  Future<void> _send(SyncOperation operation, String userId) {
    return operation.op == SyncOp.delete
        ? _sendDelete(operation)
        : _sendUpsert(operation, userId);
  }

  Future<void> _sendUpsert(SyncOperation operation, String userId) async {
    final row = await _rows.findById(operation.entity, operation.entityId);
    // Sumiu do sqflite entre enfileirar e enviar: quem manda é o local, e a
    // operação de delete que veio depois cuida do lado remoto.
    if (row == null) return;
    final data = SyncPayload.fromRow(operation.entity, row);
    if (data == null) return;

    await _tablesDb.upsertRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: operation.entity,
      rowId: operation.entityId,
      data: {...data, 'userId': userId},
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );
  }

  Future<void> _sendDelete(SyncOperation operation) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    try {
      await _tablesDb.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: operation.entity,
        rowId: operation.entityId,
        data: {'deletedAt': now, 'updatedAt': now},
      );
    } on AppwriteException catch (e) {
      // Não existe lá: a exclusão já está cumprida.
      if (e.code == 404) return;
      rethrow;
    }
  }

  bool _isPermanent(AppwriteException e) {
    final code = e.code;
    if (code == null || code == 0) return false;
    if (code == 401 || code == 403 || code == 408 || code == 429) return false;
    return code >= 400 && code < 500;
  }

  String _describe(AppwriteException e) {
    final code = e.code ?? 0;
    return '$code ${e.type ?? ''} ${e.message ?? ''}'.trim();
  }
}
