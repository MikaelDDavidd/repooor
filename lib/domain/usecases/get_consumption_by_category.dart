import '../entities/product.dart';
import '../repositories/purchase_repository.dart';

class GetConsumptionByCategory {
  GetConsumptionByCategory(this._repository);

  final PurchaseRepository _repository;

  Future<Map<String, double>> call(
    DateTime startDate,
    DateTime endDate,
    List<Product> products,
  ) async {
    final items = await _repository.getAllItemsByDateRange(startDate, endDate);
    final productMap = {for (final p in products) p.id: p};
    final result = <String, double>{};

    for (final item in items) {
      final product = productMap[item.productId];
      if (product == null) continue;
      result[product.categoryId] =
          (result[product.categoryId] ?? 0) + item.quantity;
    }

    return result;
  }
}
