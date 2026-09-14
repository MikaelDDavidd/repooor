import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/nfce/parsers/pe_nfce_parser.dart';
import 'package:repooor/domain/entities/nfce/nfce_qr_payload.dart';

void main() {
  late String html;
  setUpAll(() {
    html = File('test/fixtures/nfce/pe_sample_1.html').readAsStringSync();
  });

  const parser = PeNfceParser();
  const payload = NfceQrPayload(
    chave: '26240612345678901234567890123456789012345678',
    uf: 'PE',
    rawUrl: 'http://nfce.sefazpe.gov.br/qr',
  );

  test('returns PE as UF', () {
    expect(parser.uf, 'PE');
  });

  test('extracts emitente name', () {
    final invoice = parser.parse(html, payload);
    expect(invoice.emitenteNome, 'SUPERMERCADO EXEMPLO LTDA');
  });

  test('extracts CNPJ', () {
    final invoice = parser.parse(html, payload);
    expect(invoice.emitenteCnpj, '12.345.678/0001-90');
  });

  test('extracts issuedAt with date and time', () {
    final invoice = parser.parse(html, payload);
    expect(invoice.issuedAt.year, 2026);
    expect(invoice.issuedAt.month, 5);
    expect(invoice.issuedAt.day, 15);
    expect(invoice.issuedAt.hour, 18);
    expect(invoice.issuedAt.minute, 42);
  });

  test('extracts all 4 items from fixture', () {
    final invoice = parser.parse(html, payload);
    expect(invoice.items, hasLength(4));
  });

  test('first item has correct fields', () {
    final invoice = parser.parse(html, payload);
    final first = invoice.items.first;
    expect(first.rawName, 'ARROZ TIPO 1 TIO JOAO 5KG');
    expect(first.quantity, 2);
    expect(first.unitRaw, 'UN');
    expect(first.unitPrice, 28.90);
    expect(first.totalPrice, 57.80);
  });

  test('decimal quantity (KG) is parsed correctly', () {
    final invoice = parser.parse(html, payload);
    final cheese = invoice.items.firstWhere(
      (i) => i.rawName.contains('QUEIJO'),
    );
    expect(cheese.quantity, closeTo(0.358, 0.001));
    expect(cheese.unitRaw, 'KG');
    expect(cheese.unitPrice, 49.90);
  });

  test('totalPrice of invoice sums priced items', () {
    final invoice = parser.parse(html, payload);
    expect(invoice.totalPrice, closeTo(112.33, 0.05));
  });

  test('throws NfceParseException when html has no items', () {
    expect(
      () => parser.parse('<html><body><p>vazio</p></body></html>', payload),
      throwsA(isA<Exception>()),
    );
  });
}
