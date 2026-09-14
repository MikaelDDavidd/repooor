class StringNormalizer {
  StringNormalizer._();

  static const _diacritics = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
  };

  static String normalize(String input) {
    var result = input.toLowerCase().trim();
    result = _stripDiacritics(result);
    result = _stripLeadingEan(result);
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
    return result;
  }

  static String _stripDiacritics(String input) {
    final buffer = StringBuffer();
    for (final char in input.split('')) {
      buffer.write(_diacritics[char] ?? char);
    }
    return buffer.toString();
  }

  static String _stripLeadingEan(String input) {
    final match = RegExp(r'^\d{8,14}\s*[-:]?\s*').firstMatch(input);
    if (match == null) return input;
    return input.substring(match.end);
  }
}
