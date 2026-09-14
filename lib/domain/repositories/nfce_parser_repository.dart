import '../entities/nfce/nfce_invoice.dart';
import '../entities/nfce/nfce_qr_payload.dart';

abstract class NfceParserRepository {
  NfceInvoice parse(String html, NfceQrPayload payload);
}
