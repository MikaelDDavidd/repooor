import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/repositories/auth_repository.dart';
import 'sync_bootstrap.dart';
import 'sync_pusher.dart';
import 'sync_queue_local_ds.dart';
import 'sync_status.dart';

class SyncEngine {
  SyncEngine({
    required AuthRepository auth,
    required SyncPusher pusher,
    required SyncBootstrap bootstrap,
    required SyncQueueLocalDs queue,
    Connectivity? connectivity,
  }) : _auth = auth,
       _pusher = pusher,
       _bootstrap = bootstrap,
       _queue = queue,
       _connectivity = connectivity ?? Connectivity();

  final AuthRepository _auth;
  final SyncPusher _pusher;
  final SyncBootstrap _bootstrap;
  final SyncQueueLocalDs _queue;
  final Connectivity _connectivity;

  final _controller = StreamController<SyncStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  var _status = const SyncStatus();
  var _running = false;

  SyncStatus get status => _status;

  Stream<SyncStatus> get statusStream => _controller.stream;

  void start() {
    _connectivitySubscription ??= _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) syncNow();
    });
    syncNow();
  }

  Future<void> syncNow() async {
    if (_running) return;
    _running = true;
    try {
      final user = await _auth.currentUser();
      if (user == null) {
        await _emitCounts(SyncPhase.idle);
        return;
      }

      _emit(_status.copyWith(phase: SyncPhase.syncing));
      await _bootstrap.ensure(user.id);
      final result = await _pusher.push(userId: user.id);

      if (result.interrupted) {
        await _emitCounts(SyncPhase.waitingConnection, message: result.error);
      } else if (result.rejected > 0) {
        await _emitCounts(SyncPhase.error);
      } else {
        await _emitCounts(SyncPhase.idle);
      }
    } catch (e) {
      await _emitCounts(SyncPhase.error, message: e.toString());
    } finally {
      _running = false;
    }
  }

  Future<void> refreshCounts() => _emitCounts(_status.phase);

  Future<void> _emitCounts(SyncPhase phase, {String? message}) async {
    final pending = await _queue.countPending();
    final rejected = await _queue.countFailed();
    _emit(
      SyncStatus(
        phase: phase,
        pending: pending,
        rejected: rejected,
        message: message,
      ),
    );
  }

  void _emit(SyncStatus status) {
    _status = status;
    if (!_controller.isClosed) _controller.add(status);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _controller.close();
  }
}
