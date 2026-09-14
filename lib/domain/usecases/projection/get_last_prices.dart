import '../../entities/price_point.dart';
import '../../repositories/purchase_repository.dart';

class GetLastPrices {
  const GetLastPrices(this._repository);

  final PurchaseRepository _repository;

  Future<Map<String, PricePoint>> call() async {
    final purchases = await _repository.getAll();
    final latest = <String, PricePoint>{};
    for (final purchase in purchases) {
      if (purchase.isPlanned) continue;
      for (final item in purchase.items) {
        if (item.unitPrice == null) continue;
        final current = latest[item.productId];
        if (current != null && !purchase.date.isAfter(current.date)) continue;
        latest[item.productId] = PricePoint(
          date: purchase.date,
          unitPrice: item.unitPrice!,
          quantity: item.quantity,
        );
      }
    }
    return latest;
  }
}
