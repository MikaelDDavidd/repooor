import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/usecases/get_pantry_items.dart';
import '../../domain/usecases/add_to_pantry.dart';
import '../../domain/usecases/update_pantry_quantity.dart';
import '../../domain/usecases/update_ideal_quantity.dart';
import '../../domain/usecases/remove_from_pantry.dart';
import '../../core/di/providers.dart';

const _uuid = Uuid();

final pantryProvider = AsyncNotifierProvider<PantryNotifier, List<PantryItem>>(
  PantryNotifier.new,
);

final lowStockCountProvider = FutureProvider<int>((ref) async {
  final items = await ref.watch(pantryProvider.future);
  return items.where((i) => i.isLowStock).length;
});

class PantryNotifier extends AsyncNotifier<List<PantryItem>> {
  GetPantryItems get _getAll => ref.watch(getPantryItemsProvider);
  AddToPantry get _add => ref.watch(addToPantryProvider);
  UpdatePantryQuantity get _updateQty => ref.watch(updatePantryQuantityProvider);
  UpdateIdealQuantity get _updateIdeal => ref.watch(updateIdealQuantityProvider);
  RemoveFromPantry get _remove => ref.watch(removeFromPantryProvider);

  @override
  Future<List<PantryItem>> build() => _getAll();

  Future<void> addItem(String productId, double currentQty, double idealQty) async {
    final item = PantryItem(
      id: _uuid.v4(),
      productId: productId,
      currentQuantity: currentQty,
      idealQuantity: idealQty,
    );
    await _add(item);
    ref.invalidateSelf();
  }

  Future<void> updateQuantity(String id, double quantity) async {
    await _updateQty(id, quantity);
    ref.invalidateSelf();
  }

  Future<void> updateIdeal(String id, double quantity) async {
    await _updateIdeal(id, quantity);
    ref.invalidateSelf();
  }

  Future<void> removeItem(String id) async {
    await _remove(id);
    ref.invalidateSelf();
  }

  Future<void> incrementQuantity(String id, double amount) async {
    final items = state.valueOrNull ?? [];
    final matches1 = items.where((i) => i.id == id);
    final item = matches1.isNotEmpty ? matches1.first : null;
    if (item == null) return;
    await _updateQty(id, item.currentQuantity + amount);
    ref.invalidateSelf();
  }

  Future<void> decrementQuantity(String id, double amount) async {
    final items = state.valueOrNull ?? [];
    final matches2 = items.where((i) => i.id == id);
    final item = matches2.isNotEmpty ? matches2.first : null;
    if (item == null) return;
    final newQty = (item.currentQuantity - amount).clamp(0.0, double.infinity);
    await _updateQty(id, newQty);
    ref.invalidateSelf();
  }
}
