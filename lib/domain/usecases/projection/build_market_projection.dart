import '../../entities/projection/market_projection.dart';
import '../../entities/projection/projected_item.dart';
import '../../repositories/pantry_repository.dart';
import '../../repositories/product_repository.dart';
import 'get_last_prices.dart';

class BuildMarketProjection {
  const BuildMarketProjection(
    this._pantryRepository,
    this._productRepository,
    this._getLastPrices,
  );

  final PantryRepository _pantryRepository;
  final ProductRepository _productRepository;
  final GetLastPrices _getLastPrices;

  Future<MarketProjection> call() async {
    final pantryItems = await _pantryRepository.getAll();
    final products = await _productRepository.getAll();
    final productMap = {for (final p in products) p.id: p};
    final lastPrices = await _getLastPrices();

    final items = <ProjectedItem>[];
    for (final pantryItem in pantryItems) {
      if (pantryItem.deficit <= 0) continue;
      final product = productMap[pantryItem.productId];
      if (product == null) continue;
      final lastPrice = lastPrices[pantryItem.productId];
      items.add(
        ProjectedItem(
          product: product,
          quantity: pantryItem.deficit,
          currentQuantity: pantryItem.currentQuantity,
          idealQuantity: pantryItem.idealQuantity,
          unitPrice: lastPrice?.unitPrice,
          lastPriceDate: lastPrice?.date,
        ),
      );
    }

    items.sort(
      (a, b) =>
          a.product.name.toLowerCase().compareTo(b.product.name.toLowerCase()),
    );
    return MarketProjection(items: items);
  }
}
