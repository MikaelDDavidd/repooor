import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/sync_providers.dart';
import '../../data/sync/sync_status.dart';
import 'auth_providers.dart';

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  // Entrar ou sair da conta muda quem é o dono da fila: reavalia na hora.
  ref.listen(authStateProvider, (_, _) => engine.syncNow());
  // Só depois que o provider devolver o stream é que existe alguém escutando;
  // arrancar antes disso perderia o primeiro "sincronizando".
  Future.microtask(engine.start);
  return engine.statusStream;
});
