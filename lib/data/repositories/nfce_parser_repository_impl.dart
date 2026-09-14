import '../../domain/entities/nfce/nfce_invoice.dart';
import '../../domain/entities/nfce/nfce_qr_payload.dart';
import '../../domain/repositories/nfce_parser_repository.dart';
import '../nfce/parsers/nfce_parser_factory.dart';
import '../nfce/parsers/nfce_xml_parser.dart';

class NfceParserRepositoryImpl implements NfceParserRepository {
  const NfceParserRepositoryImpl(this._factory, this._xmlParser);

  final NfceParserFactory _factory;
  final NfceXmlParser _xmlParser;

  @override
  NfceInvoice parse(String html, NfceQrPayload payload) {
    if (NfceXmlParser.canParse(html)) return _xmlParser.parse(html, payload);
    return _factory.forUf(payload.uf).parse(html, payload);
  }
}
