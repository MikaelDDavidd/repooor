import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/pantry_item.dart';
import '../../providers/home_providers.dart';
import '../../providers/product_providers.dart';

class LowStockList extends ConsumerWidget {
  const LowStockList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStock = ref.watch(topLowStockProvider);
    final products = ref.watch(productsProvider);

    return lowStock.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        final withDeficit = items.where((i) => i.deficit > 0).toList();
        if (withDeficit.isEmpty) return const SizedBox.shrink();
        return _buildSection(context, withDeficit, products);
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    List<PantryItem> items,
    AsyncValue products,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Estoque baixo', style: AppTextStyles.heading2),
            TextButton(
              onPressed: () => context.go('/pantry'),
              child: const Text('Ver tudo'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => _buildTile(item, products)),
      ],
    );
  }

  Widget _buildTile(PantryItem item, AsyncValue products) {
    final productMatches = products.valueOrNull?.where((p) => p.id == item.productId);
    final product = (productMatches != null && productMatches.isNotEmpty) ? productMatches.first : null;
    final stockColor = item.isLowStock ? AppColors.error : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              product?.name ?? 'Produto',
              style: AppTextStyles.body,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.stockRatio.clamp(0.0, 1.0),
                backgroundColor: AppColors.backgroundSecondary,
                color: stockColor,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.currentQuantity.toStringAsFixed(0)}/${item.idealQuantity.toStringAsFixed(0)}',
            style: AppTextStyles.caption.copyWith(color: stockColor),
          ),
        ],
      ),
    );
  }
}
