import '../repositories/purchase_repository.dart';

class GetTotalSpentByMonth {
  GetTotalSpentByMonth(this._repository);

  final PurchaseRepository _repository;

  Future<double> call(int year, int month) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    final purchases = await _repository.getByDateRange(start, end);
    double total = 0;
    for (final p in purchases) {
      final pTotal = p.totalPrice;
      if (pTotal != null) total += pTotal;
    }
    return total;
  }
}
