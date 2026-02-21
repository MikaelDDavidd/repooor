import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/pantry_item.dart';
import '../../providers/pantry_providers.dart';
import '../../providers/product_providers.dart';

class MissingItemsCard extends ConsumerWidget {
  const MissingItemsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantry = ref.watch(pantryProvider);
    final products = ref.watch(productsProvider);

    return pantry.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        final missing = items.where((i) => i.deficit > 0).toList()
          ..sort((a, b) => a.stockRatio.compareTo(b.stockRatio));
        if (missing.isEmpty) return const SizedBox.shrink();
        return _buildCard(context, missing, products);
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    List<PantryItem> missing,
    AsyncValue products,
  ) {
    final displayed = missing.take(5).toList();
    final hasMore = missing.length > 5;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Itens em falta', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            ...displayed.map((item) => _buildRow(item, products)),
            if (hasMore) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/pantry'),
                  child: const Text('Ver todos'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(PantryItem item, AsyncValue products) {
    final product = products.valueOrNull
        ?.where((p) => p.id == item.productId)
        .firstOrNull;
    final color = item.stockRatio < 0.5 ? AppColors.error : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              product?.name ?? 'Produto',
              style: AppTextStyles.body,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${item.currentQuantity.toStringAsFixed(0)}/${item.idealQuantity.toStringAsFixed(0)}',
            style: AppTextStyles.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
