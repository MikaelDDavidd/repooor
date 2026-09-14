import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.formatBrl', () {
    test('returns em dash when value is null', () {
      expect(CurrencyFormatter.formatBrl(null), CurrencyFormatter.empty);
    });

    test('formats positive value with BRL locale', () {
      final result = CurrencyFormatter.formatBrl(12.34);
      expect(result, contains('12,34'));
      expect(result, contains(r'R$'));
    });

    test('formats integer value with two decimals', () {
      final result = CurrencyFormatter.formatBrl(7);
      expect(result, contains('7,00'));
    });

    test('formats negative value', () {
      final result = CurrencyFormatter.formatBrl(-3.5);
      expect(result, contains('3,50'));
      expect(result, contains('-'));
    });
  });

  group('CurrencyFormatter.parseBrlInput', () {
    test('returns null for null input', () {
      expect(CurrencyFormatter.parseBrlInput(null), isNull);
    });

    test('returns null for empty string', () {
      expect(CurrencyFormatter.parseBrlInput(''), isNull);
    });

    test('returns null for non-numeric garbage', () {
      expect(CurrencyFormatter.parseBrlInput('abc'), isNull);
    });

    test('parses brazilian decimal with comma', () {
      expect(CurrencyFormatter.parseBrlInput('12,34'), 12.34);
    });

    test('parses american decimal with dot', () {
      expect(CurrencyFormatter.parseBrlInput('12.34'), 12.34);
    });

    test('parses brazilian formatted with thousand separator', () {
      expect(CurrencyFormatter.parseBrlInput('1.234,56'), 1234.56);
    });

    test('strips currency symbol', () {
      expect(CurrencyFormatter.parseBrlInput(r'R$ 9,99'), 9.99);
    });

    test('parses integer input', () {
      expect(CurrencyFormatter.parseBrlInput('15'), 15.0);
    });

    test('parses negative value', () {
      expect(CurrencyFormatter.parseBrlInput('-2,50'), -2.5);
    });
  });
}
