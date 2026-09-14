import 'package:html/dom.dart';

class DomExtractors {
  DomExtractors._();

  static String? textOfFirst(Element root, String selector) {
    final element = root.querySelector(selector);
    if (element == null) return null;
    final text = element.text.trim();
    return text.isEmpty ? null : text;
  }

  static String? textOfFirstWhere(
    Element root,
    String selector,
    bool Function(Element element) where,
  ) {
    for (final element in root.querySelectorAll(selector)) {
      if (where(element)) {
        final text = element.text.trim();
        if (text.isNotEmpty) return text;
      }
    }
    return null;
  }

  static double parseBrDecimal(String raw) {
    final cleaned = raw
        .replaceAll(RegExp(r'[^\d.,\-]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  static DateTime? parseBrDateTime(String raw) {
    final match = RegExp(
      r'(\d{2})/(\d{2})/(\d{4})(?:\s+(\d{2}):(\d{2})(?::(\d{2}))?)?',
    ).firstMatch(raw);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(3)!),
      int.parse(match.group(2)!),
      int.parse(match.group(1)!),
      int.tryParse(match.group(4) ?? '') ?? 0,
      int.tryParse(match.group(5) ?? '') ?? 0,
      int.tryParse(match.group(6) ?? '') ?? 0,
    );
  }

  static String stripWhitespace(String raw) =>
      raw.replaceAll(RegExp(r'\s+'), ' ').trim();
}
