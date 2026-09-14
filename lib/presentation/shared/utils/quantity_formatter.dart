class QuantityFormatter {
  QuantityFormatter._();

  static String format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '')
        .replaceAll('.', ',');
  }

  static String withUnit(double value, String unit) => '${format(value)} $unit';
}
