import '../repositories/purchase_repository.dart';

class ProductConsumptionPoint {
  const ProductConsumptionPoint({
    required this.date,
    required this.quantity,
  });

  final DateTime date;
  final double quantity;
}

class GetConsumptionByProduct {
  GetConsumptionByProduct(this._repository);

  final PurchaseRepository _repository;

  Future<List<ProductConsumptionPoint>> call(
    String productId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final purchases = await _repository.getByDateRange(startDate, endDate);
    final points = <ProductConsumptionPoint>[];

    for (final purchase in purchases) {
      for (final item in purchase.items) {
        if (item.productId == productId) {
          points.add(ProductConsumptionPoint(
            date: purchase.date,
            quantity: item.quantity,
          ));
        }
      }
    }

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }
}
