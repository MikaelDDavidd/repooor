import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/purchase_item.dart';

class PurchasePlanSummary extends StatelessWidget {
  const PurchasePlanSummary({super.key, required this.items});

  final List<PurchaseItem> items;

  double? get _plannedTotal {
    final planned = items.where((i) => i.plannedTotalPrice != null);
    if (planned.isEmpty) return null;
    return planned.fold<double>(0, (sum, i) => sum + i.plannedTotalPrice!);
  }

  double? get _actualTotal {
    final priced = items.where((i) => i.totalPrice != null);
    if (priced.isEmpty) return null;
    return priced.fold<double>(0, (sum, i) => sum + i.totalPrice!);
  }

  bool get _isReconciled =>
      items.any((i) => i.wasPlanned && i.totalPrice != i.plannedTotalPrice);

  @override
  Widget build(BuildContext context) {
    final planned = _plannedTotal;
    if (planned == null) return const SizedBox.shrink();
    final actual = _actualTotal;
    final difference = actual == null ? null : actual - planned;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Projetado x real', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            _Line(label: 'Projetado', value: planned),
            const SizedBox(height: 6),
            _Line(
              label: _isReconciled ? 'Real' : 'Estimado agora',
              value: actual,
            ),
            if (difference != null) ...[
              const Divider(height: 20),
              _DifferenceLine(difference: difference, planned: planned),
            ],
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            CurrencyFormatter.formatBrl(value),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _DifferenceLine extends StatelessWidget {
  const _DifferenceLine({required this.difference, required this.planned});

  final double difference;
  final double planned;

  @override
  Widget build(BuildContext context) {
    final isOver = difference > 0;
    final color = isOver ? AppColors.warning : AppColors.primaryStrong;
    final percent = planned == 0 ? null : (difference / planned) * 100;
    final signal = isOver ? '+' : '';

    return Row(
      children: [
        Expanded(
          child: Text(
            isOver ? 'Passou do previsto' : 'Abaixo do previsto',
            style: AppTextStyles.bodySecondary.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            percent == null
                ? '$signal${CurrencyFormatter.formatBrl(difference)}'
                : '$signal${CurrencyFormatter.formatBrl(difference)} (${percent.toStringAsFixed(1)}%)',
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
