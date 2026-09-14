import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../shared/utils/quantity_formatter.dart';

class PurchaseItemPriceLabel extends StatelessWidget {
  const PurchaseItemPriceLabel({
    super.key,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    this.onFilledBackground = false,
  });

  final double quantity;
  final String unit;
  final double? unitPrice;
  final bool onFilledBackground;

  String get _qtyText => QuantityFormatter.withUnit(quantity, unit);

  Color get _mutedColor => onFilledBackground
      ? AppColors.textPrimary.withValues(alpha: 0.6)
      : AppColors.textSecondary;

  Color get _priceColor =>
      onFilledBackground ? AppColors.textPrimary : AppColors.primaryStrong;

  @override
  Widget build(BuildContext context) {
    final mutedStyle = AppTextStyles.caption.copyWith(color: _mutedColor);
    if (unitPrice == null) {
      return Text(
        _qtyText,
        style: mutedStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    final total = unitPrice! * quantity;

    // Quebra em duas linhas quando a quantidade e o valor não couberem
    // lado a lado (tela estreita ou fonte grande do sistema).
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(_qtyText, style: mutedStyle),
        Text(' · ', style: mutedStyle),
        Text(
          CurrencyFormatter.formatBrl(total),
          style: AppTextStyles.caption.copyWith(
            color: _priceColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
