import 'package:uuid/uuid.dart';
import '../../entities/nfce/imported_item_match.dart';
import '../../entities/nfce/match_type.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class EnsureMatchedProducts {
  EnsureMatchedProducts(this._productRepository, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final ProductRepository _productRepository;
  final Uuid _uuid;

  Future<List<ImportedItemMatch>> call(List<ImportedItemMatch> matches) async {
    final result = <ImportedItemMatch>[];
    for (final match in matches) {
      if (match.type != MatchType.willCreateNew) {
        result.add(match);
        continue;
      }
      final product = Product(
        id: _uuid.v4(),
        name: match.newProductName ?? match.source.rawName,
        categoryId: match.newProductCategoryId ?? '',
        unit: match.resolvedUnit,
      );
      await _productRepository.create(product);
      result.add(
        match.copyWith(
          type: MatchType.exact,
          matchedProduct: product,
          clearNewProductName: true,
          clearNewProductCategoryId: true,
        ),
      );
    }
    return result;
  }
}
