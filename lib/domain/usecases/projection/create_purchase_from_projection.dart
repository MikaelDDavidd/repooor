import 'package:uuid/uuid.dart';
import '../../entities/projection/market_projection.dart';
import '../../entities/purchase.dart';
import '../../entities/purchase_item.dart';
import '../../repositories/purchase_repository.dart';

class CreatePurchaseFromProjection {
  CreatePurchaseFromProjection(
    this._purchaseRepository,
    this._purchaseItemRepository, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final PurchaseRepository _purchaseRepository;
  final PurchaseItemRepository _purchaseItemRepository;
  final Uuid _uuid;

  Future<String> call(
    MarketProjection projection, {
    required PurchaseType type,
    DateTime? date,
  }) async {
    if (projection.isEmpty) {
      throw StateError('Projeção sem itens');
    }
    final purchaseId = _uuid.v4();
    await _purchaseRepository.create(
      Purchase(
        id: purchaseId,
        date: date ?? DateTime.now(),
        type: type,
        status: PurchaseStatus.planned,
      ),
    );
    for (final item in projection.items) {
      await _purchaseItemRepository.addItem(
        PurchaseItem(
          id: _uuid.v4(),
          purchaseId: purchaseId,
          productId: item.product.id,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          plannedQuantity: item.quantity,
          plannedUnitPrice: item.unitPrice,
          picked: item.picked,
        ),
      );
    }
    return purchaseId;
  }
}
