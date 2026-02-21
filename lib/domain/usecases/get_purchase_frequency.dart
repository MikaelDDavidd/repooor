import '../repositories/purchase_repository.dart';

class GetPurchaseFrequency {
  GetPurchaseFrequency(this._repository);

  final PurchaseRepository _repository;

  Future<Map<String, int>> call(DateTime startDate, DateTime endDate) async {
    final purchases = await _repository.getByDateRange(startDate, endDate);
    final result = <String, int>{};

    for (final purchase in purchases) {
      final key =
          '${purchase.date.year}-${purchase.date.month.toString().padLeft(2, '0')}';
      result[key] = (result[key] ?? 0) + 1;
    }

    return result;
  }
}
