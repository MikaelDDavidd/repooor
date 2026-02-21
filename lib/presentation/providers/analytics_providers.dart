import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_top_products.dart';
import '../../domain/usecases/get_consumption_by_product.dart';
import '../../core/di/providers.dart';
import 'product_providers.dart';

enum AnalyticsPeriod {
  lastMonth,
  threeMonths,
  sixMonths,
  oneYear;

  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case AnalyticsPeriod.lastMonth:
        return DateTime(now.year, now.month - 1, now.day);
      case AnalyticsPeriod.threeMonths:
        return DateTime(now.year, now.month - 3, now.day);
      case AnalyticsPeriod.sixMonths:
        return DateTime(now.year, now.month - 6, now.day);
      case AnalyticsPeriod.oneYear:
        return DateTime(now.year - 1, now.month, now.day);
    }
  }
}

final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>(
  (_) => AnalyticsPeriod.threeMonths,
);

final consumptionByCategoryProvider = FutureProvider<Map<String, double>>((ref) async {
  final period = ref.watch(analyticsPeriodProvider);
  final products = await ref.watch(productsProvider.future);
  final usecase = ref.watch(getConsumptionByCategoryProvider);
  return usecase(period.startDate, DateTime.now(), products);
});

final topProductsProvider = FutureProvider<List<TopProductResult>>((ref) async {
  final period = ref.watch(analyticsPeriodProvider);
  final usecase = ref.watch(getTopProductsProvider);
  return usecase(period.startDate, DateTime.now());
});

final purchaseFrequencyProvider = FutureProvider<Map<String, int>>((ref) async {
  final period = ref.watch(analyticsPeriodProvider);
  final usecase = ref.watch(getPurchaseFrequencyProvider);
  return usecase(period.startDate, DateTime.now());
});

final consumptionByProductProvider = FutureProvider.family<List<ProductConsumptionPoint>, String>((ref, productId) async {
  final period = ref.watch(analyticsPeriodProvider);
  final usecase = ref.watch(getConsumptionByProductProvider);
  return usecase(productId, period.startDate, DateTime.now());
});
