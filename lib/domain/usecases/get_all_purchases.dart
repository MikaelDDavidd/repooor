import '../entities/purchase.dart';
import '../repositories/purchase_repository.dart';

class GetAllPurchases {
  GetAllPurchases(this._repository);

  final PurchaseRepository _repository;

  Future<List<Purchase>> call() => _repository.getAll();
}
