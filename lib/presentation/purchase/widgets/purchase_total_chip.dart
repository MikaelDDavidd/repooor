import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';

class PurchaseTotalChip extends StatelessWidget {
  const PurchaseTotalChip({
    super.key,
    required this.total,
    this.partial = false,
  });

  final double? total;
  final bool partial;

  @override
  Widget build(BuildContext context) {
    if (total == null) return const SizedBox.shrink();

    final label = partial ? 'Parcial' : 'Total';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$label · ',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryStrong,
            ),
          ),
          Text(
            CurrencyFormatter.formatBrl(total),
            style: AppTextStyles.body.copyWith(
              color: AppColors.primaryStrong,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
