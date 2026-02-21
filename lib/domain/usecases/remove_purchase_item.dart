import '../repositories/purchase_repository.dart';

class RemovePurchaseItem {
  RemovePurchaseItem(this._repository);

  final PurchaseItemRepository _repository;

  Future<void> call(String itemId) => _repository.removeItem(itemId);
}
