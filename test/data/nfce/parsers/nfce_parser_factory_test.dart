import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/nfce/parsers/nfce_parser.dart';
import 'package:repooor/data/nfce/parsers/nfce_parser_factory.dart';
import 'package:repooor/data/nfce/parsers/pe_nfce_parser.dart';
import 'package:repooor/domain/entities/nfce/nfce_invoice.dart';
import 'package:repooor/domain/entities/nfce/nfce_qr_payload.dart';
import 'package:repooor/domain/exceptions/nfce_exception.dart';

class _DummyParser implements NfceParser {
  const _DummyParser(this.uf);
  @override
  final String uf;
  @override
  NfceInvoice parse(String html, NfceQrPayload payload) =>
      throw UnimplementedError();
}

void main() {
  group('NfceParserFactory', () {
    test('returns parser for registered uppercase UF', () {
      final factory = NfceParserFactory([const PeNfceParser()]);
      expect(factory.forUf('PE'), isA<PeNfceParser>());
    });

    test('is case-insensitive for UF lookup', () {
      final factory = NfceParserFactory([const PeNfceParser()]);
      expect(factory.forUf('pe'), isA<PeNfceParser>());
    });

    test('throws NfceUnsupportedStateException when UF is unknown', () {
      final factory = NfceParserFactory([const PeNfceParser()]);
      expect(
        () => factory.forUf('SP'),
        throwsA(isA<NfceUnsupportedStateException>()),
      );
    });

    test('supportedUfs returns set of registered UFs', () {
      final factory = NfceParserFactory([
        const PeNfceParser(),
        const _DummyParser('PB'),
        const _DummyParser('AL'),
      ]);
      expect(factory.supportedUfs, {'PE', 'PB', 'AL'});
    });
  });
}
