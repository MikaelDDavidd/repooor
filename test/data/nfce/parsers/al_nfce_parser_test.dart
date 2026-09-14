import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/nfce/parsers/al_nfce_parser.dart';
import 'package:repooor/domain/entities/nfce/nfce_qr_payload.dart';

void main() {
  late String html;
  setUpAll(() {
    html = File('test/fixtures/nfce/al_sample_1.html').readAsStringSync();
  });

  const parser = AlNfceParser();
  const payload = NfceQrPayload(
    chave: '27240612345678901234567890123456789012345678',
    uf: 'AL',
    rawUrl: 'http://nfce.sefazal.gov.br/qr',
  );

  test('uf is AL', () {
    expect(parser.uf, 'AL');
  });

  test('extracts emitente, CNPJ and date with seconds', () {
    final invoice = parser.parse(html, payload);
    expect(invoice.emitenteNome, 'SUPERMERCADO MACEIO LTDA');
    expect(invoice.emitenteCnpj, '11.222.333/0001-44');
    expect(invoice.issuedAt.day, 8);
    expect(invoice.issuedAt.hour, 19);
    expect(invoice.issuedAt.minute, 5);
  });

  test('extracts 4 items including PCT and KG units', () {
    final invoice = parser.parse(html, payload);
    expect(invoice.items, hasLength(4));
    final bono = invoice.items.firstWhere((i) => i.rawName.contains('BONO'));
    expect(bono.unitRaw, 'PCT');
    expect(bono.quantity, 4);
    final alcatra = invoice.items.firstWhere(
      (i) => i.rawName.contains('ALCATRA'),
    );
    expect(alcatra.unitRaw, 'KG');
    expect(alcatra.quantity, closeTo(1.236, 0.001));
    expect(alcatra.unitPrice, 49.90);
  });

  test('totalPrice sums priced items', () {
    final invoice = parser.parse(html, payload);
    expect(invoice.totalPrice, closeTo(121.51, 0.05));
  });
}
