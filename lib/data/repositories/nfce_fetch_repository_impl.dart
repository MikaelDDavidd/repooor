import '../../domain/entities/nfce/nfce_qr_payload.dart';
import '../../domain/repositories/nfce_fetch_repository.dart';
import '../datasources/nfce_remote_ds.dart';

class NfceFetchRepositoryImpl implements NfceFetchRepository {
  const NfceFetchRepositoryImpl(this._ds);

  final NfceRemoteDs _ds;

  @override
  Future<String> fetchHtml(NfceQrPayload payload) =>
      _ds.fetchHtml(payload.rawUrl);
}
