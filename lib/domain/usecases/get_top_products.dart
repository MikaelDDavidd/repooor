import '../repositories/purchase_repository.dart';

class TopProductResult {
  const TopProductResult({
    required this.productId,
    required this.totalQuantity,
  });

  final String productId;
  final double totalQuantity;
}

class GetTopProducts {
  GetTopProducts(this._repository);

  final PurchaseRepository _repository;

  Future<List<TopProductResult>> call(
    DateTime startDate,
    DateTime endDate, {
    int limit = 10,
  }) async {
    final items = await _repository.getAllItemsByDateRange(startDate, endDate);
    final totals = <String, double>{};

    for (final item in items) {
      totals[item.productId] = (totals[item.productId] ?? 0) + item.quantity;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(limit)
        .map((e) => TopProductResult(productId: e.key, totalQuantity: e.value))
        .toList();
  }
}
