import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/purchase_item.dart';
import '../../domain/usecases/get_all_purchases.dart';
import '../../domain/usecases/create_purchase.dart';
import '../../domain/usecases/delete_purchase.dart';
import '../../domain/usecases/complete_purchase.dart';
import '../../domain/usecases/add_purchase_item.dart';
import '../../domain/usecases/update_purchase_item.dart';
import '../../domain/usecases/remove_purchase_item.dart';
import '../../core/di/providers.dart';
import 'pantry_providers.dart';

const _uuid = Uuid();

final purchasesProvider = AsyncNotifierProvider<PurchasesNotifier, List<Purchase>>(
  PurchasesNotifier.new,
);

final activePurchaseProvider = StateProvider<String?>((_) => null);

final activePurchaseDetailProvider = FutureProvider<Purchase?>((ref) async {
  final id = ref.watch(activePurchaseProvider);
  if (id == null) return null;
  final getPurchase = ref.watch(getPurchaseByIdProvider);
  return getPurchase(id);
});

class PurchasesNotifier extends AsyncNotifier<List<Purchase>> {
  GetAllPurchases get _getAll => ref.watch(getAllPurchasesProvider);
  CreatePurchase get _create => ref.watch(createPurchaseProvider);
  DeletePurchase get _delete => ref.watch(deletePurchaseProvider);
  CompletePurchase get _complete => ref.watch(completePurchaseProvider);

  @override
  Future<List<Purchase>> build() => _getAll();

  Future<String> createNew(PurchaseType type, {DateTime? date}) async {
    final id = _uuid.v4();
    final purchase = Purchase(
      id: id,
      date: date ?? DateTime.now(),
      type: type,
    );
    await _create(purchase);
    ref.invalidateSelf();
    return id;
  }

  Future<void> completePurchase(String purchaseId) async {
    await _complete(purchaseId);
    ref.invalidateSelf();
    ref.invalidate(pantryProvider);
  }

  Future<void> remove(String id) async {
    await _delete(id);
    ref.invalidateSelf();
  }
}

final purchaseItemsProvider = AsyncNotifierProvider.family<PurchaseItemsNotifier, List<PurchaseItem>, String>(
  PurchaseItemsNotifier.new,
);

class PurchaseItemsNotifier extends FamilyAsyncNotifier<List<PurchaseItem>, String> {
  AddPurchaseItem get _addItem => ref.read(addPurchaseItemProvider);
  UpdatePurchaseItem get _updateItem => ref.read(updatePurchaseItemProvider);
  RemovePurchaseItem get _removeItem => ref.read(removePurchaseItemProvider);

  @override
  Future<List<PurchaseItem>> build(String arg) async {
    final getPurchase = ref.watch(getPurchaseByIdProvider);
    final purchase = await getPurchase(arg);
    return purchase?.items ?? [];
  }

  Future<void> addItem(String productId, double quantity) async {
    final item = PurchaseItem(
      id: _uuid.v4(),
      purchaseId: arg,
      productId: productId,
      quantity: quantity,
    );
    await _addItem(item);
    ref.invalidateSelf();
  }

  Future<void> updateItem(String itemId, double quantity) async {
    final items = state.valueOrNull ?? [];
    final matches = items.where((i) => i.id == itemId);
    final existing = matches.isNotEmpty ? matches.first : null;
    if (existing == null) return;
    await _updateItem(existing.copyWith(quantity: quantity));
    ref.invalidateSelf();
  }

  Future<void> removeItem(String itemId) async {
    await _removeItem(itemId);
    ref.invalidateSelf();
  }
}
