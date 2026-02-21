import '../repositories/purchase_repository.dart';

class RemovePurchaseItem {
  RemovePurchaseItem(this._repository);

  final PurchaseRepository _repository;

  Future<void> call(String itemId) => _repository.removeItem(itemId);
}
