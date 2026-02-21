import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/product.dart';
import '../providers/pantry_providers.dart';
import '../providers/product_providers.dart';
import '../providers/category_providers.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/app_loading_state.dart';
import '../shared/widgets/confirm_dialog.dart';
import 'pantry_add_page.dart';
import 'pantry_edit_dialog.dart';

class PantryPage extends ConsumerWidget {
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantry = ref.watch(pantryProvider);
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Despensa')),
      body: pantry.when(
        loading: () => const AppLoadingState(),
        error: (e, _) => AppErrorState(
          message: 'Erro ao carregar despensa',
          onRetry: () => ref.invalidate(pantryProvider),
        ),
        data: (items) => _buildList(context, ref, items, products, categories),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PantryAddPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<PantryItem> items,
    AsyncValue<List<Product>> products,
    AsyncValue categories,
  ) {
    if (items.isEmpty) {
      return AppEmptyState(
        icon: Icons.kitchen_outlined,
        title: 'Despensa vazia',
        subtitle: 'Adicione produtos para controlar seu estoque',
        action: ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PantryAddPage()),
          ),
          child: const Text('Adicionar produto'),
        ),
      );
    }
    final sorted = List<PantryItem>.from(items)
      ..sort((a, b) => a.stockRatio.compareTo(b.stockRatio));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = sorted[index];
        final product = products.valueOrNull
            ?.where((p) => p.id == item.productId)
            .firstOrNull;
        final category = categories.valueOrNull
            ?.where((c) => c.id == product?.categoryId)
            .firstOrNull;
        return _PantryTile(
          item: item,
          product: product,
          categoryIcon: category != null
              ? IconData(category.icon, fontFamily: 'MaterialIcons')
              : Icons.category,
          categoryColor: category != null
              ? Color(category.color)
              : AppColors.textSecondary,
          onTap: () => PantryEditDialog.show(context, item: item, product: product),
          onIncrement: () => ref.read(pantryProvider.notifier).incrementQuantity(item.id, 1),
          onDecrement: () => ref.read(pantryProvider.notifier).decrementQuantity(item.id, 1),
          onDelete: () async {
            final confirmed = await ConfirmDialog.show(
              context,
              title: 'Remover da despensa',
              content: 'Remover "${product?.name ?? 'item'}" da despensa?',
              confirmLabel: 'Remover',
              isDestructive: true,
            );
            if (confirmed == true) {
              ref.read(pantryProvider.notifier).removeItem(item.id);
            }
          },
        );
      },
    );
  }
}

class _PantryTile extends StatelessWidget {
  const _PantryTile({
    required this.item,
    required this.product,
    required this.categoryIcon,
    required this.categoryColor,
    required this.onTap,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  final PantryItem item;
  final Product? product;
  final IconData categoryIcon;
  final Color categoryColor;
  final VoidCallback onTap;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  Color get _stockColor {
    if (item.isLowStock) return AppColors.error;
    if (item.isMediumStock) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (_) async => await ConfirmDialog.show(
        context,
        title: 'Remover',
        content: 'Remover "${product?.name ?? 'item'}" da despensa?',
        confirmLabel: 'Remover',
        isDestructive: true,
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildCategoryIcon(),
                const SizedBox(width: 12),
                Expanded(child: _buildInfo()),
                const SizedBox(width: 8),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: AppColors.onPrimary),
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(categoryIcon, color: categoryColor, size: 22),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product?.name ?? 'Produto', style: AppTextStyles.body),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.stockRatio.clamp(0.0, 1.0),
                  backgroundColor: AppColors.backgroundSecondary,
                  color: _stockColor,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${item.currentQuantity.toStringAsFixed(0)}/${item.idealQuantity.toStringAsFixed(0)}',
              style: AppTextStyles.caption.copyWith(color: _stockColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline, size: 22),
          color: AppColors.textSecondary,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline, size: 22),
          color: AppColors.primary,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
