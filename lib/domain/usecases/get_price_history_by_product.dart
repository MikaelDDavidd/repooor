import '../entities/price_point.dart';
import '../repositories/purchase_repository.dart';

class GetPriceHistoryByProduct {
  GetPriceHistoryByProduct(this._repository);

  final PurchaseRepository _repository;

  Future<List<PricePoint>> call(String productId) async {
    final purchases = await _repository.getAll();
    final points = <PricePoint>[];
    for (final purchase in purchases) {
      for (final item in purchase.items) {
        if (item.productId != productId || item.unitPrice == null) continue;
        points.add(
          PricePoint(
            date: purchase.date,
            unitPrice: item.unitPrice!,
            quantity: item.quantity,
          ),
        );
      }
    }
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }
}
