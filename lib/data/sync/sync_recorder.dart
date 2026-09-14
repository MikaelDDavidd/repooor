import 'package:uuid/uuid.dart';
import 'sync_operation.dart';
import 'sync_queue_local_ds.dart';

// Enfileirar não pode derrubar a escrita local: o dado no sqflite é a fonte da
// verdade e continua valendo mesmo que a sincronização falhe.
class SyncRecorder {
  SyncRecorder(this._queue, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final SyncQueueLocalDs _queue;
  final Uuid _uuid;

  Future<void> recordUpsert(String entity, String entityId) =>
      _record(entity, entityId, SyncOp.upsert);

  Future<void> recordDelete(String entity, String entityId) =>
      _record(entity, entityId, SyncOp.delete);

  Future<void> recordUpsertAll(
    String entity,
    Iterable<String> entityIds,
  ) async {
    final operations = [
      for (final entityId in entityIds) _build(entity, entityId, SyncOp.upsert),
    ];
    try {
      await _queue.enqueueAll(operations);
    } catch (_) {}
  }

  Future<void> _record(String entity, String entityId, SyncOp op) async {
    try {
      await _queue.enqueue(_build(entity, entityId, op));
    } catch (_) {}
  }

  SyncOperation _build(String entity, String entityId, SyncOp op) {
    return SyncOperation(
      id: _uuid.v4(),
      entity: entity,
      entityId: entityId,
      op: op,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
