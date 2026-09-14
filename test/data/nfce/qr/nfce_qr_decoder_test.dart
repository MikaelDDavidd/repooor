import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/nfce/qr/nfce_qr_decoder.dart';
import 'package:repooor/domain/exceptions/nfce_exception.dart';

void main() {
  group('NfceQrDecoder.decode', () {
    test('throws when text is empty', () {
      expect(
        () => NfceQrDecoder.decode('  '),
        throwsA(isA<NfceInvalidQrException>()),
      );
    });

    test('throws when text is not an URL', () {
      expect(
        () => NfceQrDecoder.decode(
          'apenas texto livre 26240612345678901234567890123456789012345678',
        ),
        throwsA(isA<NfceInvalidQrException>()),
      );
    });

    test('throws when URL has no 44-digit key', () {
      expect(
        () => NfceQrDecoder.decode('https://nfce.sefazpe.gov.br/qr?p=abc'),
        throwsA(isA<NfceInvalidQrException>()),
      );
    });

    test('decodes a valid PE URL with pipe-separated params', () {
      final payload = NfceQrDecoder.decode(
        'http://nfce.sefazpe.gov.br/qrcode?p=26240612345678901234567890123456789012345678|2|1|1|abc',
      );
      expect(payload.chave, '26240612345678901234567890123456789012345678');
      expect(payload.uf, 'PE');
      expect(payload.versao, '2');
      expect(payload.tpAmb, '1');
    });

    test('decodes a valid PB URL by chave fallback', () {
      final payload = NfceQrDecoder.decode(
        'https://unknown.host/qr?p=25240612345678901234567890123456789012345678',
      );
      expect(payload.uf, 'PB');
      expect(payload.chave.length, 44);
    });

    test('returns the rawUrl trimmed', () {
      final payload = NfceQrDecoder.decode(
        '  http://nfce.sefazpe.gov.br/q?p=26240612345678901234567890123456789012345678  ',
      );
      expect(payload.rawUrl.startsWith('http'), isTrue);
      expect(payload.rawUrl.endsWith(' '), isFalse);
    });
  });
}
