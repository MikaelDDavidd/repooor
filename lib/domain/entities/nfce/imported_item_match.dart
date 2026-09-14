import '../product.dart';
import 'match_type.dart';
import 'nfce_raw_item.dart';

class ImportedItemMatch {
  const ImportedItemMatch({
    required this.source,
    required this.type,
    required this.resolvedQuantity,
    required this.resolvedUnit,
    this.matchedProduct,
    this.suggestions = const [],
    this.resolvedUnitPrice,
    this.newProductName,
    this.newProductCategoryId,
  });

  final NfceRawItem source;
  final MatchType type;
  final Product? matchedProduct;
  final List<Product> suggestions;
  final double resolvedQuantity;
  final String resolvedUnit;
  final double? resolvedUnitPrice;
  final String? newProductName;
  final String? newProductCategoryId;

  bool get isResolved => type != MatchType.unresolved;

  ImportedItemMatch copyWith({
    NfceRawItem? source,
    MatchType? type,
    Product? matchedProduct,
    bool clearMatchedProduct = false,
    List<Product>? suggestions,
    double? resolvedQuantity,
    String? resolvedUnit,
    double? resolvedUnitPrice,
    bool clearUnitPrice = false,
    String? newProductName,
    bool clearNewProductName = false,
    String? newProductCategoryId,
    bool clearNewProductCategoryId = false,
  }) {
    return ImportedItemMatch(
      source: source ?? this.source,
      type: type ?? this.type,
      matchedProduct: clearMatchedProduct
          ? null
          : (matchedProduct ?? this.matchedProduct),
      suggestions: suggestions ?? this.suggestions,
      resolvedQuantity: resolvedQuantity ?? this.resolvedQuantity,
      resolvedUnit: resolvedUnit ?? this.resolvedUnit,
      resolvedUnitPrice: clearUnitPrice
          ? null
          : (resolvedUnitPrice ?? this.resolvedUnitPrice),
      newProductName: clearNewProductName
          ? null
          : (newProductName ?? this.newProductName),
      newProductCategoryId: clearNewProductCategoryId
          ? null
          : (newProductCategoryId ?? this.newProductCategoryId),
    );
  }
}
