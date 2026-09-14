import 'package:uuid/uuid.dart';
import '../../entities/nfce/nfce_import_draft.dart';
import '../../entities/purchase.dart';
import '../../entities/purchase_item.dart';
import '../../exceptions/nfce_exception.dart';
import '../../repositories/purchase_repository.dart';
import 'ensure_matched_products.dart';

class ImportNfceAsPurchase {
  ImportNfceAsPurchase(
    this._ensureProducts,
    this._purchaseRepository,
    this._purchaseItemRepository, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final EnsureMatchedProducts _ensureProducts;
  final PurchaseRepository _purchaseRepository;
  final PurchaseItemRepository _purchaseItemRepository;
  final Uuid _uuid;

  Future<String> call(NfceImportDraft draft) async {
    try {
      final resolved = await _ensureProducts(draft.matches);
      final purchaseId = _uuid.v4();
      final purchase = Purchase(
        id: purchaseId,
        date: draft.invoice.issuedAt,
        type: draft.targetType,
      );
      await _purchaseRepository.create(purchase);
      for (final match in resolved) {
        await _purchaseItemRepository.addItem(
          PurchaseItem(
            id: _uuid.v4(),
            purchaseId: purchaseId,
            productId: match.matchedProduct!.id,
            quantity: match.resolvedQuantity,
            unitPrice: match.resolvedUnitPrice,
          ),
        );
      }
      return purchaseId;
    } on NfceException {
      rethrow;
    } catch (e) {
      throw NfceImportException(e.toString());
    }
  }
}
