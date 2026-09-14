import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sync/sync_bootstrap.dart';
import '../../data/sync/sync_engine.dart';
import '../../data/sync/sync_pusher.dart';
import '../../data/sync/sync_queue_local_ds.dart';
import '../../data/sync/sync_recorder.dart';
import '../../data/sync/sync_row_local_ds.dart';
import '../../data/sync/sync_state_local_ds.dart';
import 'auth_providers.dart';

final tablesDbProvider = Provider<TablesDB>(
  (ref) => TablesDB(ref.watch(appwriteClientProvider)),
);

final syncQueueLocalDsProvider = Provider<SyncQueueLocalDs>(
  (_) => SyncQueueLocalDs(),
);
final syncRowLocalDsProvider = Provider<SyncRowLocalDs>(
  (_) => SyncRowLocalDs(),
);
final syncStateLocalDsProvider = Provider<SyncStateLocalDs>(
  (_) => SyncStateLocalDs(),
);

final syncRecorderProvider = Provider<SyncRecorder>(
  (ref) => SyncRecorder(ref.watch(syncQueueLocalDsProvider)),
);

final syncPusherProvider = Provider<SyncPusher>(
  (ref) => SyncPusher(
    ref.watch(tablesDbProvider),
    ref.watch(syncQueueLocalDsProvider),
    ref.watch(syncRowLocalDsProvider),
  ),
);

final syncBootstrapProvider = Provider<SyncBootstrap>(
  (ref) => SyncBootstrap(
    ref.watch(syncRowLocalDsProvider),
    ref.watch(syncRecorderProvider),
    ref.watch(syncStateLocalDsProvider),
  ),
);

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    auth: ref.watch(authRepositoryProvider),
    pusher: ref.watch(syncPusherProvider),
    bootstrap: ref.watch(syncBootstrapProvider),
    queue: ref.watch(syncQueueLocalDsProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});
