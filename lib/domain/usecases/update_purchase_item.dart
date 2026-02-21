import '../entities/purchase_item.dart';
import '../repositories/purchase_repository.dart';

class UpdatePurchaseItem {
  UpdatePurchaseItem(this._repository);

  final PurchaseRepository _repository;

  Future<void> call(PurchaseItem item) => _repository.updateItem(item);
}
