import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _brl = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 2,
  );

  static const String empty = '—';

  static String formatBrl(double? value) {
    if (value == null) return empty;
    return _brl.format(value);
  }

  static double? parseBrlInput(String? raw) {
    if (raw == null) return null;
    final cleaned = raw.replaceAll(RegExp(r'[^\d,.\-]'), '').trim();
    if (cleaned.isEmpty) return null;
    final normalized = _normalizeDecimal(cleaned);
    return double.tryParse(normalized);
  }

  static String _normalizeDecimal(String input) {
    final hasComma = input.contains(',');
    final hasDot = input.contains('.');
    if (hasComma && hasDot) {
      return input.replaceAll('.', '').replaceAll(',', '.');
    }
    if (hasComma) {
      return input.replaceAll(',', '.');
    }
    return input;
  }
}
