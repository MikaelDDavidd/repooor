import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/nfce/parsers/nfce_xml_parser.dart';
import 'package:repooor/domain/entities/nfce/nfce_qr_payload.dart';
import 'package:repooor/domain/exceptions/nfce_exception.dart';

void main() {
  late String xml;
  setUpAll(() {
    xml = File('test/fixtures/nfce/pe_sample_2.xml').readAsStringSync();
  });

  const parser = NfceXmlParser();
  const payload = NfceQrPayload(
    chave: '26260741797488000107650010000587661002268142',
    uf: 'PE',
    rawUrl: 'https://nfce.sefaz.pe.gov.br:444/nfce-web/consultarNFCe?p=x',
  );

  group('canParse', () {
    test('accepts xml declaration', () {
      expect(NfceXmlParser.canParse(xml), isTrue);
    });

    test('accepts nfeProc without declaration', () {
      expect(NfceXmlParser.canParse('<nfeProc></nfeProc>'), isTrue);
    });

    test('rejects html document', () {
      expect(NfceXmlParser.canParse('<html><body></body></html>'), isFalse);
    });
  });

  group('parse', () {
    test('extracts emitente name and formatted cnpj', () {
      final invoice = parser.parse(xml, payload);
      expect(invoice.emitenteNome, 'SUPERMERCADO EXEMPLO LTDA');
      expect(invoice.emitenteCnpj, '12.345.678/0001-90');
    });

    test('extracts uf from enderEmit', () {
      expect(parser.parse(xml, payload).uf, 'PE');
    });

    test('extracts chave from infNFe Id', () {
      final invoice = parser.parse(xml, payload);
      expect(invoice.chave, '26260741797488000107650010000587661002268142');
    });

    test('extracts issuedAt from dhEmi', () {
      final invoice = parser.parse(xml, payload);
      final expected = DateTime.parse('2026-07-02T18:50:28-03:00').toLocal();
      expect(invoice.issuedAt, expected);
    });

    test('extracts all items', () {
      expect(parser.parse(xml, payload).items, hasLength(3));
    });

    test('parses dot decimals without losing scale', () {
      final first = parser.parse(xml, payload).items.first;
      expect(first.rawName, 'Leite Po Camponesa instantaneo 200G');
      expect(first.quantity, 1);
      expect(first.unitRaw, 'Sch');
      expect(first.unitPrice, 6.8);
    });

    test('parses fractional quantity', () {
      final racao = parser
          .parse(xml, payload)
          .items
          .firstWhere((i) => i.rawName.contains('racao'));
      expect(racao.quantity, closeTo(0.898, 0.0001));
      expect(racao.unitPrice, 18.25);
      expect(racao.unitRaw, 'KG');
    });

    test('falls back to cProd when cEAN is SEM GTIN', () {
      final items = parser.parse(xml, payload).items;
      expect(items.first.code, '7896259412267');
      expect(items.last.code, '003000');
    });

    test('sums invoice total from items', () {
      expect(parser.parse(xml, payload).totalPrice, closeTo(35.49, 0.01));
    });

    test('throws NfceParseException on sefaz error element', () {
      const errorXml =
          '<?xml version="1.0"?><nfeProc><erro>NFC-e nao encontrada</erro></nfeProc>';
      expect(
        () => parser.parse(errorXml, payload),
        throwsA(isA<NfceParseException>()),
      );
    });

    test('throws NfceParseException on malformed xml', () {
      expect(
        () => parser.parse('<?xml version="1.0"?><nfeProc><unclosed>', payload),
        throwsA(isA<NfceParseException>()),
      );
    });

    test('throws NfceParseException when there are no items', () {
      const emptyXml =
          '<?xml version="1.0"?><nfeProc><NFe><infNFe Id="NFe26"></infNFe></NFe></nfeProc>';
      expect(
        () => parser.parse(emptyXml, payload),
        throwsA(isA<NfceParseException>()),
      );
    });
  });
}
