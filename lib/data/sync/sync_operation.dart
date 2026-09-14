enum SyncOp { upsert, delete }

class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      id: map['id'] as String,
      entity: map['entity'] as String,
      entityId: map['entity_id'] as String,
      op: SyncOp.values.firstWhere(
        (value) => value.name == map['op'],
        orElse: () => SyncOp.upsert,
      ),
      createdAt: (map['created_at'] as num).toInt(),
      attempts: (map['attempts'] as num?)?.toInt() ?? 0,
      lastError: map['last_error'] as String?,
    );
  }

  final String id;
  final String entity;
  final String entityId;
  final SyncOp op;
  final int createdAt;
  final int attempts;
  final String? lastError;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity': entity,
      'entity_id': entityId,
      'op': op.name,
      'created_at': createdAt,
      'attempts': attempts,
      'last_error': lastError,
    };
  }
}
