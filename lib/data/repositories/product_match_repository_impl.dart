import '../../core/constants/nfce_units_map.dart';
import '../../core/utils/string_normalizer.dart';
import '../../domain/entities/nfce/imported_item_match.dart';
import '../../domain/entities/nfce/match_type.dart';
import '../../domain/entities/nfce/nfce_raw_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_match_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/nfce/suggest_category_for_name.dart';
import '../matching/product_name_matcher.dart';

class ProductMatchRepositoryImpl implements ProductMatchRepository {
  ProductMatchRepositoryImpl(this._productRepository, this._suggestCategory);

  final ProductRepository _productRepository;
  final SuggestCategoryForName _suggestCategory;

  static const int _suggestionLimit = 3;

  @override
  Future<ImportedItemMatch> findMatch(NfceRawItem item) async {
    final products = await _productRepository.getAll();
    final resolvedUnit = nfceUnitFromRaw(item.unitRaw).label;

    final exact = _findExact(products, item.rawName);
    if (exact != null) {
      return _matched(item, exact, MatchType.exact, resolvedUnit);
    }

    final ranked = ProductNameMatcher.rank<Product>(
      rawName: item.rawName,
      candidates: products,
      nameOf: (p) => p.name,
    ).take(_suggestionLimit).toList();

    if (ranked.isEmpty) {
      return _buildWillCreateNew(item, resolvedUnit, const []);
    }

    final suggestions = ranked.map((r) => r.value).toList();
    final best = ranked.first;

    if (best.score >= ProductNameMatcher.highConfidence) {
      return _matched(
        item,
        best.value,
        MatchType.fuzzyHigh,
        resolvedUnit,
        suggestions: suggestions,
      );
    }
    if (best.score >= ProductNameMatcher.lowConfidence) {
      return _matched(
        item,
        best.value,
        MatchType.fuzzyLow,
        resolvedUnit,
        suggestions: suggestions,
      );
    }
    return _buildWillCreateNew(item, resolvedUnit, suggestions);
  }

  @override
  Future<List<Product>> searchSuggestions(String query, {int limit = 5}) async {
    final products = await _productRepository.getAll();
    if (StringNormalizer.normalize(query).isEmpty) {
      return products.take(limit).toList();
    }
    final ranked = ProductNameMatcher.rank<Product>(
      rawName: query,
      candidates: products,
      nameOf: (p) => p.name,
    );
    return ranked.take(limit).map((r) => r.value).toList();
  }

  Product? _findExact(List<Product> products, String rawName) {
    for (final product in products) {
      if (ProductNameMatcher.isSameName(product.name, rawName)) return product;
    }
    return null;
  }

  ImportedItemMatch _matched(
    NfceRawItem item,
    Product product,
    MatchType type,
    String resolvedUnit, {
    List<Product> suggestions = const [],
  }) {
    return ImportedItemMatch(
      source: item,
      type: type,
      matchedProduct: product,
      suggestions: suggestions,
      resolvedQuantity: item.quantity,
      resolvedUnit: resolvedUnit,
      resolvedUnitPrice: item.unitPrice,
    );
  }

  Future<ImportedItemMatch> _buildWillCreateNew(
    NfceRawItem item,
    String resolvedUnit,
    List<Product> suggestions,
  ) async {
    final normalizedName = StringNormalizer.normalize(item.rawName);
    final categoryId = await _suggestCategory(normalizedName);
    return ImportedItemMatch(
      source: item,
      type: MatchType.willCreateNew,
      suggestions: suggestions,
      resolvedQuantity: item.quantity,
      resolvedUnit: resolvedUnit,
      resolvedUnitPrice: item.unitPrice,
      newProductName: _titleCase(normalizedName),
      newProductCategoryId: categoryId,
    );
  }

  String _titleCase(String normalized) {
    return normalized
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
