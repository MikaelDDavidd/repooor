import '../entities/purchase.dart';
import '../repositories/purchase_repository.dart';

class GetPurchaseById {
  GetPurchaseById(this._repository);

  final PurchaseRepository _repository;

  Future<Purchase?> call(String id) => _repository.getById(id);
}
