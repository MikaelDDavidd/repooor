import 'package:uuid/uuid.dart';
import '../entities/pantry_item.dart';
import '../entities/purchase.dart';
import '../repositories/pantry_repository.dart';
import '../repositories/purchase_repository.dart';

class CompletePurchase {
  CompletePurchase(
    this._purchaseRepository,
    this._pantryRepository, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final PurchaseRepository _purchaseRepository;
  final PantryRepository _pantryRepository;
  final Uuid _uuid;

  Future<void> call(String purchaseId) async {
    final purchase = await _purchaseRepository.getById(purchaseId);
    if (purchase == null) return;

    final boughtByProduct = <String, double>{};
    for (final item in purchase.items) {
      if (item.quantity <= 0) continue;
      boughtByProduct[item.productId] =
          (boughtByProduct[item.productId] ?? 0) + item.quantity;
    }

    for (final entry in boughtByProduct.entries) {
      final existing = await _pantryRepository.getByProductId(entry.key);
      if (existing == null) {
        await _pantryRepository.add(
          PantryItem(
            id: _uuid.v4(),
            productId: entry.key,
            currentQuantity: entry.value,
            idealQuantity: entry.value,
          ),
        );
        continue;
      }
      await _pantryRepository.updateQuantity(
        existing.id,
        existing.currentQuantity + entry.value,
      );
    }

    if (purchase.isPlanned) {
      await _purchaseRepository.updateStatus(
        purchaseId,
        PurchaseStatus.completed,
      );
    }
  }
}
