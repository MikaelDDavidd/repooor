import '../repositories/product_repository.dart';
import '../repositories/purchase_repository.dart';

class GetTotalSpentByCategory {
  GetTotalSpentByCategory(this._purchaseRepository, this._productRepository);

  final PurchaseRepository _purchaseRepository;
  final ProductRepository _productRepository;

  Future<Map<String, double>> call(DateTime start, DateTime end) async {
    final products = await _productRepository.getAll();
    final productCategory = {for (final p in products) p.id: p.categoryId};
    final items = await _purchaseRepository.getAllItemsByDateRange(start, end);
    final totals = <String, double>{};
    for (final item in items) {
      final total = item.totalPrice;
      if (total == null) continue;
      final categoryId = productCategory[item.productId];
      if (categoryId == null) continue;
      totals[categoryId] = (totals[categoryId] ?? 0) + total;
    }
    return totals;
  }
}
