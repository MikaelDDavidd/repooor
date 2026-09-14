import '../entities/nfce/nfce_qr_payload.dart';

abstract class NfceFetchRepository {
  Future<String> fetchHtml(NfceQrPayload payload);
}
