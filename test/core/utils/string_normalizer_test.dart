import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/core/utils/string_normalizer.dart';

void main() {
  group('StringNormalizer.normalize', () {
    test('lowercases input', () {
      expect(StringNormalizer.normalize('ARROZ'), 'arroz');
    });

    test('removes diacritics', () {
      expect(StringNormalizer.normalize('Açúcar Cristão'), 'acucar cristao');
    });

    test('strips leading EAN code with dash', () {
      expect(
        StringNormalizer.normalize('7891234567890 - Leite Integral'),
        'leite integral',
      );
    });

    test('strips leading EAN code without separator', () {
      expect(StringNormalizer.normalize('78912345 Arroz'), 'arroz');
    });

    test('keeps numbers shorter than 8 digits intact', () {
      expect(StringNormalizer.normalize('1234 Maçã'), '1234 maca');
    });

    test('collapses repeated whitespace', () {
      expect(StringNormalizer.normalize('Café    forte'), 'cafe forte');
    });

    test('trims leading and trailing whitespace', () {
      expect(StringNormalizer.normalize('  Pão  '), 'pao');
    });

    test('does not remove digits that are not EAN-length', () {
      expect(StringNormalizer.normalize('Leite 1L'), 'leite 1l');
    });
  });
}
