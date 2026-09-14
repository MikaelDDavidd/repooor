import '../../../domain/exceptions/nfce_exception.dart';
import 'nfce_parser.dart';

class NfceParserFactory {
  NfceParserFactory(Iterable<NfceParser> parsers)
    : _parsers = {for (final p in parsers) p.uf.toUpperCase(): p};

  final Map<String, NfceParser> _parsers;

  Set<String> get supportedUfs => _parsers.keys.toSet();

  NfceParser forUf(String uf) {
    final parser = _parsers[uf.toUpperCase()];
    if (parser == null) {
      throw NfceUnsupportedStateException(uf: uf);
    }
    return parser;
  }
}
