import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/pantry_item.dart';
import '../../../domain/entities/purchase.dart';

class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    super.key,
    required this.product,
    this.pantryItem,
    this.lastPurchase,
  });

  final Product product;
  final PantryItem? pantryItem;
  final Purchase? lastPurchase;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (pantryItem != null || lastPurchase != null) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _buildContext(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: AppTextStyles.body),
              const SizedBox(height: 2),
              Text(product.unit, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContext() {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        if (pantryItem != null)
          _buildChip(
            Icons.kitchen_outlined,
            '${pantryItem!.currentQuantity.toStringAsFixed(0)}/${pantryItem!.idealQuantity.toStringAsFixed(0)}',
            pantryItem!.isLowStock ? AppColors.error : AppColors.primary,
          ),
        if (lastPurchase != null)
          _buildChip(
            Icons.shopping_cart_outlined,
            '${lastPurchase!.date.day}/${lastPurchase!.date.month}/${lastPurchase!.date.year}',
            AppColors.textSecondary,
          ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.caption.copyWith(color: color)),
      ],
    );
  }
}
