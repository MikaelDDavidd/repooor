import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/domain/exceptions/nfce_exception.dart';
import 'package:repooor/domain/usecases/nfce/parse_nfce_qr_payload.dart';

void main() {
  const usecase = ParseNfceQrPayload();

  test('returns payload for supported state (PE)', () {
    final payload = usecase(
      'http://nfce.sefazpe.gov.br/qr?p=26240612345678901234567890123456789012345678',
    );
    expect(payload.uf, 'PE');
  });

  test('returns payload for supported state (PB) via chave', () {
    final payload = usecase(
      'https://unknown.host/qr?p=25240612345678901234567890123456789012345678',
    );
    expect(payload.uf, 'PB');
  });

  test('throws NfceUnsupportedStateException for SP', () {
    expect(
      () => usecase(
        'http://nfce.sefazsp.gov.br/qr?p=35240612345678901234567890123456789012345678',
      ),
      throwsA(isA<NfceUnsupportedStateException>()),
    );
  });

  test('throws NfceInvalidQrException for empty input', () {
    expect(() => usecase(''), throwsA(isA<NfceInvalidQrException>()));
  });

  test('throws NfceInvalidQrException for non-URL text', () {
    expect(
      () => usecase('foo bar baz'),
      throwsA(isA<NfceInvalidQrException>()),
    );
  });
}
