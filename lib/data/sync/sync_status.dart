enum SyncPhase { idle, syncing, waitingConnection, error }

class SyncStatus {
  const SyncStatus({
    this.phase = SyncPhase.idle,
    this.pending = 0,
    this.rejected = 0,
    this.message,
  });

  final SyncPhase phase;
  final int pending;
  final int rejected;
  final String? message;

  bool get hasPendingWork => pending > 0;

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pending,
    int? rejected,
    String? message,
  }) {
    return SyncStatus(
      phase: phase ?? this.phase,
      pending: pending ?? this.pending,
      rejected: rejected ?? this.rejected,
      message: message,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SyncStatus &&
        other.phase == phase &&
        other.pending == pending &&
        other.rejected == rejected &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(phase, pending, rejected, message);
}
