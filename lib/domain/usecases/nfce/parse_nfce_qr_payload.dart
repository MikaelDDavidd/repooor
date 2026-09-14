import '../../../core/constants/nfce_supported_states.dart';
import '../../../data/nfce/qr/nfce_qr_decoder.dart';
import '../../entities/nfce/nfce_qr_payload.dart';
import '../../exceptions/nfce_exception.dart';

class ParseNfceQrPayload {
  const ParseNfceQrPayload();

  NfceQrPayload call(String rawQrText) {
    final payload = NfceQrDecoder.decode(rawQrText);
    if (!isNfceStateSupported(payload.uf)) {
      throw NfceUnsupportedStateException(uf: payload.uf);
    }
    return payload;
  }
}
