import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/home_providers.dart';

class PantrySummaryCard extends ConsumerWidget {
  const PantrySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(pantrySummaryProvider);

    return Card(
      child: InkWell(
        onTap: () => context.go('/pantry'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: summary.when(
            loading: () => _buildContent(context, null, null),
            error: (_, _) => _buildError(),
            data: (data) => _buildContent(
              context,
              data.totalItems,
              data.lowStockCount,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, int? total, int? lowStock) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.kitchen_outlined, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Despensa', style: AppTextStyles.heading2),
              const SizedBox(height: 2),
              total == null
                  ? Text('Carregando...', style: AppTextStyles.caption)
                  : Text(
                      '$total itens${lowStock != null && lowStock > 0 ? ' \u00b7 $lowStock em falta' : ''}',
                      style: AppTextStyles.caption,
                    ),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildError() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.kitchen_outlined, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Despensa', style: AppTextStyles.heading2),
              const SizedBox(height: 2),
              Text('Erro ao carregar', style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}
