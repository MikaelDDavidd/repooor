import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/projection_providers.dart';
import '../../domain/entities/projection/market_projection.dart';
import '../../domain/entities/purchase.dart';
import 'purchase_providers.dart';

final marketProjectionProvider =
    AsyncNotifierProvider<MarketProjectionNotifier, MarketProjection>(
      MarketProjectionNotifier.new,
    );

class MarketProjectionNotifier extends AsyncNotifier<MarketProjection> {
  static const quantityStep = 1.0;

  @override
  Future<MarketProjection> build() =>
      ref.watch(buildMarketProjectionProvider)();

  void increment(int index) => _changeQuantity(index, quantityStep);

  void decrement(int index) => _changeQuantity(index, -quantityStep);

  void _changeQuantity(int index, double delta) {
    final current = state.valueOrNull;
    if (current == null || index >= current.items.length) return;
    final item = current.items[index];
    final next = (item.quantity + delta).clamp(0.0, double.infinity).toDouble();
    state = AsyncData(
      current.replaceItem(index, item.copyWith(quantity: next)),
    );
  }

  void setQuantity(int index, double quantity) {
    final current = state.valueOrNull;
    if (current == null || index >= current.items.length) return;
    final item = current.items[index];
    state = AsyncData(
      current.replaceItem(
        index,
        item.copyWith(
          quantity: quantity.clamp(0.0, double.infinity).toDouble(),
        ),
      ),
    );
  }

  void setUnitPrice(int index, double? unitPrice) {
    final current = state.valueOrNull;
    if (current == null || index >= current.items.length) return;
    final item = current.items[index];
    state = AsyncData(
      current.replaceItem(
        index,
        item.copyWith(unitPrice: unitPrice, clearUnitPrice: unitPrice == null),
      ),
    );
  }

  void pick(int index, {required double quantity, double? unitPrice}) {
    final current = state.valueOrNull;
    if (current == null || index >= current.items.length) return;
    final item = current.items[index];
    state = AsyncData(
      current.replaceItem(
        index,
        item.copyWith(
          quantity: quantity,
          unitPrice: unitPrice,
          clearUnitPrice: unitPrice == null,
          picked: true,
        ),
      ),
    );
  }

  void unpick(int index) {
    final current = state.valueOrNull;
    if (current == null || index >= current.items.length) return;
    final item = current.items[index];
    state = AsyncData(current.replaceItem(index, item.copyWith(picked: false)));
  }

  void removeItem(int index) {
    final current = state.valueOrNull;
    if (current == null || index >= current.items.length) return;
    state = AsyncData(current.removeItem(index));
  }

  Future<String> confirm(PurchaseType type) async {
    final current = state.valueOrNull;
    if (current == null) throw StateError('Projeção não carregada');
    final buyable = MarketProjection(
      items: current.items.where((i) => i.quantity > 0).toList(),
    );
    final purchaseId = await ref.read(createPurchaseFromProjectionProvider)(
      buyable,
      type: type,
    );
    ref.invalidate(purchasesProvider);
    ref.invalidateSelf();
    return purchaseId;
  }
}
