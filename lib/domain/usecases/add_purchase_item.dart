import '../entities/purchase_item.dart';
import '../repositories/purchase_repository.dart';

class AddPurchaseItem {
  AddPurchaseItem(this._repository);

  final PurchaseItemRepository _repository;

  Future<void> call(PurchaseItem item) => _repository.addItem(item);
}
