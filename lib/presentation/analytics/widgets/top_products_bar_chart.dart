import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/get_top_products.dart';
import '../../providers/analytics_providers.dart';
import '../../providers/product_providers.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_error_state.dart';
import '../../shared/widgets/app_loading_state.dart';

class TopProductsBarChart extends ConsumerWidget {
  const TopProductsBarChart({super.key, this.onProductTap});

  final void Function(String productId)? onProductTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topProducts = ref.watch(topProductsProvider);
    final products = ref.watch(productsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top 10 produtos', style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            topProducts.when(
              loading: () => const SizedBox(
                height: 200,
                child: AppLoadingState(),
              ),
              error: (e, _) => AppErrorState(
                message: 'Erro ao carregar dados',
                onRetry: () => ref.invalidate(topProductsProvider),
              ),
              data: (data) {
                if (data.isEmpty) {
                  return const SizedBox(
                    height: 150,
                    child: AppEmptyState(
                      icon: Icons.bar_chart,
                      title: 'Sem dados',
                      subtitle: 'Registre compras para ver o ranking',
                    ),
                  );
                }
                return _buildBars(data, products);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBars(
    List<TopProductResult> data,
    AsyncValue<List<Product>> products,
  ) {
    final prods = products.valueOrNull ?? [];
    final prodMap = {for (final p in prods) p.id: p};
    final maxValue = data.fold(
      0.0,
      (max, item) => item.totalQuantity > max ? item.totalQuantity : max,
    );

    return Column(
      children: data.map((item) {
        final name = prodMap[item.productId]?.name ?? 'Produto';
        final ratio = maxValue > 0 ? item.totalQuantity / maxValue : 0.0;

        return InkWell(
          onTap: onProductTap != null
              ? () => onProductTap!(item.productId)
              : null,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    name.length > 14 ? '${name.substring(0, 14)}...' : name,
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: AppColors.backgroundSecondary,
                      color: AppColors.primary,
                      minHeight: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  child: Text(
                    item.totalQuantity.toStringAsFixed(0),
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
