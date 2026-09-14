import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/price_point.dart';
import 'analytics_providers.dart';

final currentMonthSpendingProvider = FutureProvider<double>((ref) async {
  final now = DateTime.now();
  final usecase = ref.watch(getTotalSpentByMonthProvider);
  return usecase(now.year, now.month);
});

final spendingByCategoryProvider = FutureProvider<Map<String, double>>((
  ref,
) async {
  final period = ref.watch(analyticsPeriodProvider);
  final usecase = ref.watch(getTotalSpentByCategoryProvider);
  return usecase(period.startDate, DateTime.now());
});

final priceHistoryProvider = FutureProvider.family<List<PricePoint>, String>((
  ref,
  productId,
) async {
  final usecase = ref.watch(getPriceHistoryByProductProvider);
  return usecase(productId);
});
