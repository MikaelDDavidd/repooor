import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/purchase.dart';
import 'pantry_providers.dart';
import 'purchase_providers.dart';

class PantrySummary {
  const PantrySummary({
    required this.totalItems,
    required this.lowStockCount,
  });

  final int totalItems;
  final int lowStockCount;
}

class PurchaseSummary {
  const PurchaseSummary({
    required this.date,
    required this.type,
    required this.itemCount,
  });

  final DateTime date;
  final PurchaseType type;
  final int itemCount;
}

final pantrySummaryProvider = FutureProvider<PantrySummary>((ref) async {
  final items = await ref.watch(pantryProvider.future);
  return PantrySummary(
    totalItems: items.length,
    lowStockCount: items.where((i) => i.isLowStock).length,
  );
});

final purchaseSummaryProvider = FutureProvider<PurchaseSummary?>((ref) async {
  final purchases = await ref.watch(purchasesProvider.future);
  if (purchases.isEmpty) return null;
  final latest = purchases.first;
  return PurchaseSummary(
    date: latest.date,
    type: latest.type,
    itemCount: latest.totalItems,
  );
});

final topLowStockProvider = FutureProvider<List<PantryItem>>((ref) async {
  final items = await ref.watch(pantryProvider.future);
  final sorted = items.toList()..sort((a, b) => a.stockRatio.compareTo(b.stockRatio));
  return sorted.take(5).toList();
});
