import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/spending_providers.dart';

class CategorySpendingCard extends ConsumerWidget {
  const CategorySpendingCard({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spending = ref.watch(spendingByCategoryProvider);

    return spending.when(
      loading: () => const _Placeholder(label: 'Calculando...'),
      error: (_, _) => const _Placeholder(label: 'Erro ao calcular'),
      data: (data) => _PlacedCard(total: data[categoryId]),
    );
  }
}

class _PlacedCard extends StatelessWidget {
  const _PlacedCard({required this.total});

  final double? total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.attach_money, color: AppColors.primaryStrong),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total gasto no período', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatBrl(total),
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primaryStrong,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(label, style: AppTextStyles.bodySecondary),
      ),
    );
  }
}
