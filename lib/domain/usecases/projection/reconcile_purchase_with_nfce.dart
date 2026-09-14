import 'package:uuid/uuid.dart';
import '../../entities/nfce/nfce_import_draft.dart';
import '../../entities/purchase_item.dart';
import '../../exceptions/nfce_exception.dart';
import '../../repositories/purchase_repository.dart';
import '../nfce/ensure_matched_products.dart';

class _ScannedTotals {
  _ScannedTotals(this.quantity, this.amount);

  double quantity;
  double? amount;

  void add(double qty, double? unitPrice) {
    quantity += qty;
    if (unitPrice == null) return;
    amount = (amount ?? 0) + unitPrice * qty;
  }

  double? get unitPrice =>
      amount == null || quantity == 0 ? null : amount! / quantity;
}

class ReconcilePurchaseWithNfce {
  ReconcilePurchaseWithNfce(
    this._ensureProducts,
    this._purchaseRepository,
    this._purchaseItemRepository, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final EnsureMatchedProducts _ensureProducts;
  final PurchaseRepository _purchaseRepository;
  final PurchaseItemRepository _purchaseItemRepository;
  final Uuid _uuid;

  Future<String> call(String purchaseId, NfceImportDraft draft) async {
    try {
      final purchase = await _purchaseRepository.getById(purchaseId);
      if (purchase == null) {
        throw const NfceImportException('Compra não encontrada');
      }
      final resolved = await _ensureProducts(draft.matches);

      // A nota manda: várias linhas do mesmo produto viram um item só.
      final scanned = <String, _ScannedTotals>{};
      for (final match in resolved) {
        final productId = match.matchedProduct!.id;
        scanned
            .putIfAbsent(productId, () => _ScannedTotals(0, null))
            .add(match.resolvedQuantity, match.resolvedUnitPrice);
      }

      final plannedByProduct = <String, PurchaseItem>{};
      final duplicates = <PurchaseItem>[];
      for (final item in purchase.items) {
        final existing = plannedByProduct[item.productId];
        if (existing == null) {
          plannedByProduct[item.productId] = item;
        } else {
          duplicates.add(item);
        }
      }

      for (final entry in scanned.entries) {
        final totals = entry.value;
        final planned = plannedByProduct[entry.key];
        if (planned == null) {
          await _purchaseItemRepository.addItem(
            PurchaseItem(
              id: _uuid.v4(),
              purchaseId: purchaseId,
              productId: entry.key,
              quantity: totals.quantity,
              unitPrice: totals.unitPrice,
            ),
          );
          continue;
        }
        await _purchaseItemRepository.updateItem(
          planned.copyWith(
            quantity: totals.quantity,
            unitPrice: totals.unitPrice,
            clearUnitPrice: totals.unitPrice == null,
            plannedQuantity: planned.plannedQuantity ?? planned.quantity,
            plannedUnitPrice: planned.plannedUnitPrice ?? planned.unitPrice,
          ),
        );
      }

      for (final item in plannedByProduct.values) {
        if (scanned.containsKey(item.productId)) continue;
        await _purchaseItemRepository.updateItem(
          item.copyWith(
            quantity: 0,
            clearUnitPrice: true,
            plannedQuantity: item.plannedQuantity ?? item.quantity,
            plannedUnitPrice: item.plannedUnitPrice ?? item.unitPrice,
          ),
        );
      }

      for (final duplicate in duplicates) {
        await _purchaseItemRepository.removeItem(duplicate.id);
      }

      return purchaseId;
    } on NfceException {
      rethrow;
    } catch (e) {
      throw NfceImportException(e.toString());
    }
  }
}
