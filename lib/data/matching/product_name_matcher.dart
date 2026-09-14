import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import '../../core/constants/product_synonyms.dart';
import '../../core/utils/string_normalizer.dart';

class ProductNameMatcher {
  ProductNameMatcher._();

  static const highConfidence = 85.0;
  static const lowConfidence = 60.0;

  /// Número solto ("200", "1"). Medida com unidade ("30l", "500g") é mantida:
  /// em saco de lixo ou refrigerante o volume faz parte da identidade.
  static final _measurement = RegExp(r'^\d+([.,]\d+)?$');
  static final _unitOnly = RegExp(
    r'^(g|gr|grs|kg|kgs|mg|ml|l|lt|lts|un|und|unid|uni|pc|pcs|pct|pack|cx|dz|kit|leve|tp|c|sache|sachet|doy|com|de|do|da|e|em|para|por|no|na|a|o|as|os|tipo|tam|ref)$',
  );

  static List<String> tokenize(String raw) {
    var normalized = StringNormalizer.normalize(raw);
    normalized = _applyPhraseSynonyms(normalized);
    final parts = normalized.split(RegExp(r'[^a-z0-9]+'));
    final tokens = <String>[];
    for (final part in parts) {
      if (part.isEmpty) continue;
      if (_measurement.hasMatch(part)) continue;
      if (_unitOnly.hasMatch(part)) continue;
      if (part.length < 3 && int.tryParse(part) != null) continue;
      tokens.add(_canonical(_singularize(part)));
    }
    return tokens;
  }

  static String _applyPhraseSynonyms(String normalized) {
    var result = ' $normalized ';
    for (final entry in productPhraseSynonyms.entries) {
      result = result.replaceAll(' ${entry.key} ', ' ${entry.value} ');
    }
    return result.trim();
  }

  static String _canonical(String token) =>
      productTokenSynonyms[token] ?? token;

  static String _singularize(String token) {
    if (token.length <= 3) return token;
    if (token.endsWith('oes') || token.endsWith('aes')) {
      return '${token.substring(0, token.length - 3)}ao';
    }
    if (token.endsWith('is') && token.length > 4) {
      return '${token.substring(0, token.length - 2)}l';
    }
    if (token.endsWith('ns')) return '${token.substring(0, token.length - 2)}m';
    if (token.endsWith('s')) return token.substring(0, token.length - 1);
    return token;
  }

  static const _minPrefixMatch = 4;

  /// Casa "cond" com "condensado", mas não "sal" com "salsicha".
  static bool _tokensMatch(String a, String b) {
    if (a == b) return true;
    final shorter = a.length <= b.length ? a : b;
    final longer = a.length <= b.length ? b : a;
    if (shorter.length < _minPrefixMatch) return false;
    return longer.startsWith(shorter);
  }

  static Set<String> _sharedTokens(List<String> product, List<String> raw) {
    final shared = <String>{};
    for (final p in product) {
      for (final r in raw) {
        if (_tokensMatch(p, r)) {
          shared.add(p);
          break;
        }
      }
    }
    return shared;
  }

  static bool _containsToken(Iterable<String> tokens, String token) =>
      tokens.any((t) => _tokensMatch(t, token));

  /// Score de 0 a 100 entre o nome de um produto cadastrado e o nome cru da nota.
  /// Zero significa que não há nenhuma palavra relevante em comum.
  static double score({required String productName, required String rawName}) {
    final productTokens = tokenize(productName);
    final rawTokens = tokenize(rawName);
    if (productTokens.isEmpty || rawTokens.isEmpty) return 0;

    final sharedInProduct = _sharedTokens(productTokens, rawTokens);
    if (sharedInProduct.isEmpty) return 0;
    final sharedInRaw = _sharedTokens(rawTokens, productTokens);

    final productCoverage =
        sharedInProduct.length / productTokens.toSet().length;
    final rawCoverage = sharedInRaw.length / rawTokens.toSet().length;
    // Comparado no nome literal: desempata marcas que dividem o mesmo
    // canônico (Toddy e Nescau viram "achocolatado", mas "TODDY ORIGINAL"
    // se parece mais com Toddy).
    final fuzzy = tokenSetRatio(
      StringNormalizer.normalize(productName),
      StringNormalizer.normalize(rawName),
    ).toDouble();

    var value = 45 * productCoverage + 40 * rawCoverage + 0.15 * fuzzy;

    final matchesHeadOfRaw = _containsToken(sharedInRaw, rawTokens.first);
    if (matchesHeadOfRaw) value += 8;
    if (_containsToken(sharedInProduct, productTokens.first)) value += 3;

    // O produto não é o assunto principal do item: casou numa palavra
    // secundária e cobre pouco do nome da nota.
    if (!matchesHeadOfRaw && rawCoverage < 0.5) value -= 25;

    return value.clamp(0, 100).toDouble();
  }

  /// Ordena os candidatos do melhor para o pior, descartando os sem palavra em comum.
  static List<ScoredName<T>> rank<T>({
    required String rawName,
    required Iterable<T> candidates,
    required String Function(T) nameOf,
  }) {
    final scored = <ScoredName<T>>[];
    for (final candidate in candidates) {
      final value = score(productName: nameOf(candidate), rawName: rawName);
      if (value <= 0) continue;
      scored.add(ScoredName(candidate, value));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  static bool isSameName(String a, String b) =>
      StringNormalizer.normalize(a) == StringNormalizer.normalize(b);
}

class ScoredName<T> {
  const ScoredName(this.value, this.score);

  final T value;
  final double score;
}
