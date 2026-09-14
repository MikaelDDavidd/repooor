import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';

class ProductMatchSuggestionTile extends StatelessWidget {
  const ProductMatchSuggestionTile({
    super.key,
    required this.product,
    required this.onTap,
    this.isSelected = false,
  });

  final Product product;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 1.5 : 0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.inventory_2_outlined,
          color: AppColors.primaryStrong,
        ),
        title: Text(product.name, style: AppTextStyles.body),
        subtitle: Text(product.unit, style: AppTextStyles.caption),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primaryStrong)
            : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
