import '../entities/purchase.dart';
import '../repositories/purchase_repository.dart';

class CreatePurchase {
  CreatePurchase(this._repository);

  final PurchaseRepository _repository;

  Future<void> call(Purchase purchase) => _repository.create(purchase);
}
