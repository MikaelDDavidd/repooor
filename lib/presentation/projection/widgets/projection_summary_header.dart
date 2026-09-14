import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/projection/market_projection.dart';

class ProjectionSummaryHeader extends StatelessWidget {
  const ProjectionSummaryHeader({super.key, required this.projection});

  final MarketProjection projection;

  @override
  Widget build(BuildContext context) {
    final pending = projection.totalItems - projection.pickedCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mercado de hoje', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            _MoneyRow(
              label: 'No carrinho',
              helper:
                  '${projection.pickedCount} de ${projection.totalItems} itens',
              value: projection.pickedTotal,
              emphasis: true,
            ),
            const Divider(height: 20),
            _MoneyRow(
              label: 'Falta pegar',
              helper: '$pending ${pending == 1 ? 'item' : 'itens'}',
              value: projection.estimatedTotal - projection.pickedTotal,
            ),
            const SizedBox(height: 8),
            _MoneyRow(
              label: 'Previsão total',
              helper: 'carrinho + o que falta',
              value: projection.estimatedTotal,
            ),
            if (projection.pickedCount > 0) ...[
              const SizedBox(height: 12),
              _PickProgress(projection: projection),
            ],
            if (projection.isPartial) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${projection.itemsWithoutPrice} sem preço: a previsão está incompleta.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.helper,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String helper;
  final double value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: emphasis
                    ? AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)
                    : AppTextStyles.bodySecondary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                helper,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            CurrencyFormatter.formatBrl(value),
            style: emphasis
                ? AppTextStyles.heading2.copyWith(
                    color: AppColors.primaryStrong,
                  )
                : AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _PickProgress extends StatelessWidget {
  const _PickProgress({required this.projection});

  final MarketProjection projection;

  @override
  Widget build(BuildContext context) {
    final ratio = projection.totalItems == 0
        ? 0.0
        : projection.pickedCount / projection.totalItems;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: ratio,
        backgroundColor: AppColors.backgroundSecondary,
        color: AppColors.primaryStrong,
        minHeight: 6,
      ),
    );
  }
}
