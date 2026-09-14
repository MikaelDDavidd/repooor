import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/nfce/parsers/pb_nfce_parser.dart';
import 'package:repooor/domain/entities/nfce/nfce_qr_payload.dart';

void main() {
  late String html;
  setUpAll(() {
    html = File('test/fixtures/nfce/pb_sample_1.html').readAsStringSync();
  });

  const parser = PbNfceParser();
  const payload = NfceQrPayload(
    chave: '25240612345678901234567890123456789012345678',
    uf: 'PB',
    rawUrl: 'http://nfce.sefazpb.gov.br/qr',
  );

  test('uf is PB', () {
    expect(parser.uf, 'PB');
  });

  test('extracts emitente, CNPJ and date', () {
    final invoice = parser.parse(html, payload);
    expect(invoice.emitenteNome, 'MERCADINHO PARAIBA LTDA');
    expect(invoice.emitenteCnpj, '98.765.432/0001-21');
    expect(invoice.issuedAt.year, 2026);
    expect(invoice.issuedAt.month, 5);
    expect(invoice.issuedAt.day, 10);
  });

  test('extracts 3 items with prices', () {
    final invoice = parser.parse(html, payload);
    expect(invoice.items, hasLength(3));
    final water = invoice.items.first;
    expect(water.rawName, contains('AGUA MINERAL'));
    expect(water.quantity, 6);
    expect(water.unitPrice, 3.5);
  });

  test('handles decimal quantity (KG)', () {
    final invoice = parser.parse(html, payload);
    final tomate = invoice.items.firstWhere(
      (i) => i.rawName.contains('TOMATE'),
    );
    expect(tomate.quantity, closeTo(0.524, 0.001));
    expect(tomate.unitRaw, 'KG');
  });
}
