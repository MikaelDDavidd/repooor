import '../repositories/pantry_repository.dart';
import '../repositories/purchase_repository.dart';

class CompletePurchase {
  CompletePurchase(this._purchaseRepository, this._pantryRepository);

  final PurchaseRepository _purchaseRepository;
  final PantryRepository _pantryRepository;

  Future<void> call(String purchaseId) async {
    final purchase = await _purchaseRepository.getById(purchaseId);
    if (purchase == null) return;

    for (final item in purchase.items) {
      final pantryItem = await _pantryRepository.getByProductId(item.productId);
      if (pantryItem != null) {
        await _pantryRepository.updateQuantity(
          pantryItem.id,
          pantryItem.currentQuantity + item.quantity,
        );
      }
    }
  }
}
