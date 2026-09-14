import '../../entities/nfce/nfce_invoice.dart';
import '../../entities/nfce/nfce_qr_payload.dart';
import '../../repositories/nfce_fetch_repository.dart';
import '../../repositories/nfce_parser_repository.dart';

class FetchNfceInvoice {
  const FetchNfceInvoice(this._fetch, this._parser);

  final NfceFetchRepository _fetch;
  final NfceParserRepository _parser;

  Future<NfceInvoice> call(NfceQrPayload payload) async {
    final html = await _fetch.fetchHtml(payload);
    return _parser.parse(html, payload);
  }
}
