import '../repositories/purchase_repository.dart';

class DeletePurchase {
  DeletePurchase(this._repository);

  final PurchaseRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
