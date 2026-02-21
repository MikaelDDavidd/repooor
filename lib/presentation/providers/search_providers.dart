import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/purchase.dart';
import '../../core/di/providers.dart';
import 'pantry_providers.dart';
import 'purchase_providers.dart';

class SearchResultItem {
  const SearchResultItem({
    required this.product,
    this.pantryItem,
    this.lastPurchase,
  });

  final Product product;
  final PantryItem? pantryItem;
  final Purchase? lastPurchase;
}

final searchQueryProvider = StateProvider<String>((_) => '');

final searchResultsProvider = FutureProvider<List<SearchResultItem>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final search = ref.watch(searchProductsProvider);
  final products = await search(query);

  final pantryItems = await ref.watch(pantryProvider.future);
  final purchases = await ref.watch(purchasesProvider.future);

  final pantryByProductId = {for (final item in pantryItems) item.productId: item};

  return products.map((product) {
    Purchase? lastPurchase;
    for (final purchase in purchases) {
      final hasProduct = purchase.items.any((i) => i.productId == product.id);
      if (hasProduct) {
        lastPurchase = purchase;
        break;
      }
    }

    return SearchResultItem(
      product: product,
      pantryItem: pantryByProductId[product.id],
      lastPurchase: lastPurchase,
    );
  }).toList();
});
