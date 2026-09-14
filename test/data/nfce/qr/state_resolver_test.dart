import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/nfce/qr/state_resolver.dart';

void main() {
  group('NfceStateResolver.resolve', () {
    test('resolves PE from sefazpe host substring', () {
      final uf = NfceStateResolver.resolve(
        rawUrl: 'http://nfce.sefazpe.gov.br/nfce/consulta?p=...',
        chave: '00000000000000000000000000000000000000000000',
      );
      expect(uf, 'PE');
    });

    test('resolves PB from chave IBGE prefix when host unknown', () {
      final uf = NfceStateResolver.resolve(
        rawUrl: 'https://example.com/qrcode?p=abc',
        chave: '25240612345678901234567890123456789012345678',
      );
      expect(uf, 'PB');
    });

    test('resolves AL from chave IBGE prefix', () {
      final uf = NfceStateResolver.resolve(
        rawUrl: 'https://unknown.host/qr',
        chave: '27240612345678901234567890123456789012345678',
      );
      expect(uf, 'AL');
    });

    test('host takes precedence over chave', () {
      final uf = NfceStateResolver.resolve(
        rawUrl: 'http://nfce.sefazpe.gov.br/qr',
        chave: '35240612345678901234567890123456789012345678',
      );
      expect(uf, 'PE');
    });

    test('returns null when neither host nor chave reveal a known UF', () {
      final uf = NfceStateResolver.resolve(
        rawUrl: 'https://unknown.com/qr',
        chave: '99240612345678901234567890123456789012345678',
      );
      expect(uf, isNull);
    });
  });
}
