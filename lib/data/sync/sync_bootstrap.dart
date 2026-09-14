import '../datasources/database_migrations.dart';
import 'sync_recorder.dart';
import 'sync_row_local_ds.dart';
import 'sync_state_local_ds.dart';

// O que já existe no aparelho antes da conta existir precisa entrar na fila
// uma vez, senão os dados atuais nunca sobem.
class SyncBootstrap {
  SyncBootstrap(this._rows, this._recorder, this._state);

  final SyncRowLocalDs _rows;
  final SyncRecorder _recorder;
  final SyncStateLocalDs _state;

  static String markerKey(String userId) => 'bootstrap:$userId';

  Future<int> ensure(String userId) async {
    final key = markerKey(userId);
    if (await _state.markerOf(key) != null) return 0;

    var enqueued = 0;
    // A ordem de syncedTables respeita as dependências: categoria antes de
    // produto, compra antes de item de compra.
    for (final entity in DatabaseMigrations.syncedTables) {
      final ids = await _rows.idsOf(entity);
      if (ids.isEmpty) continue;
      await _recorder.recordUpsertAll(entity, ids);
      enqueued += ids.length;
    }

    await _state.setMarker(key, DateTime.now().millisecondsSinceEpoch);
    return enqueued;
  }
}
