import '../../../domain/entities/nfce/nfce_invoice.dart';
import '../../../domain/entities/nfce/nfce_qr_payload.dart';

abstract interface class NfceParser {
  String get uf;
  NfceInvoice parse(String html, NfceQrPayload payload);
}
