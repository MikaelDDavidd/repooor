import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/price_point.dart';
import '../../providers/spending_providers.dart';

class PriceSummaryCard extends ConsumerWidget {
  const PriceSummaryCard({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(priceHistoryProvider(productId));
    return history.when(
      loading: () => const _PriceSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: _buildBody,
    );
  }

  Widget _buildBody(List<PricePoint> points) {
    if (points.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.price_change_outlined,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                'Sem preços registrados',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
      );
    }
    final last = points.last;
    final avg =
        points.fold<double>(0, (s, p) => s + p.unitPrice) / points.length;
    final delta = points.length >= 2
        ? ((last.unitPrice - points.first.unitPrice) / points.first.unitPrice) *
              100
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preço pago', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PriceStat(
                    label: 'Último',
                    value: CurrencyFormatter.formatBrl(last.unitPrice),
                  ),
                ),
                Expanded(
                  child: _PriceStat(
                    label: 'Médio',
                    value: CurrencyFormatter.formatBrl(avg),
                  ),
                ),
                Expanded(
                  child: _PriceStat(
                    label: 'Variação',
                    value: delta == null
                        ? '—'
                        : '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}%',
                    valueColor: delta == null
                        ? AppColors.textSecondary
                        : (delta > 0 ? AppColors.warning : AppColors.success),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceStat extends StatelessWidget {
  const _PriceStat({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: valueColor ?? AppColors.primaryStrong,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _PriceSkeleton extends StatelessWidget {
  const _PriceSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        height: 110,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
