import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.categories,
    this.onTap,
  });

  final Product product;
  final List<Category> categories;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final categoryList = categories.where((c) => c.id == product.categoryId);
    final category = categoryList.isNotEmpty ? categoryList.first : null;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category != null
                      ? Color(category.color).withValues(alpha: 0.15)
                      : AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category != null
                      ? IconData(category.icon, fontFamily: 'MaterialIcons')
                      : Icons.category,
                  color: category != null ? Color(category.color) : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppTextStyles.body),
                    const SizedBox(height: 2),
                    Text(
                      '${category?.name ?? 'Sem categoria'} · ${product.unit}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
