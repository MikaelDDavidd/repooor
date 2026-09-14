import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/category.dart';

class CategorySectionHeader extends StatelessWidget {
  const CategorySectionHeader({super.key, required this.category});

  final Category? category;

  @override
  Widget build(BuildContext context) {
    final icon = category != null
        ? IconData(category!.icon, fontFamily: 'MaterialIcons')
        : Icons.category;
    final color = category != null
        ? Color(category!.color)
        : AppColors.textSecondary;
    final name = category?.name ?? 'Outros';

    // Sem altura fixa: com a fonte grande do sistema o texto precisa crescer.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      color: AppColors.backgroundSecondary,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodySecondary.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
