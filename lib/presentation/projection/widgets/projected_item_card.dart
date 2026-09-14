import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/projection/projected_item.dart';
import '../../shared/utils/quantity_formatter.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/pick_check_button.dart';

class ProjectedItemCard extends StatelessWidget {
  const ProjectedItemCard({
    super.key,
    required this.item,
    required this.category,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onTogglePicked,
  });

  final ProjectedItem item;
  final Category? category;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final VoidCallback onTogglePicked;

  Color get _categoryColor =>
      category != null ? Color(category!.color) : AppColors.textSecondary;

  IconData get _categoryIcon => category != null
      ? IconData(category!.icon, fontFamily: 'MaterialIcons')
      : Icons.category;

  bool get _picked => item.picked;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _picked ? AppColors.primary : null,
      child: InkWell(
        onTap: onTogglePicked,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PickCheckButton(
                    picked: _picked,
                    onPressed: onTogglePicked,
                    fallbackIcon: _categoryIcon,
                    fallbackColor: _categoryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary.withValues(
                              alpha: _picked ? 0.75 : 1,
                            ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tem ${QuantityFormatter.format(item.currentQuantity)} de ${QuantityFormatter.format(item.idealQuantity)} ${item.product.unit}',
                          style: AppTextStyles.caption.copyWith(
                            color: _picked
                                ? AppColors.textPrimary.withValues(alpha: 0.6)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_picked)
                    AppIconButton(
                      icon: Icons.close,
                      color: AppColors.textPrimary.withValues(alpha: 0.75),
                      tooltip: 'Desmarcar',
                      onPressed: onTogglePicked,
                    )
                  else
                    AppIconButton(
                      icon: Icons.delete_outline,
                      color: AppColors.textSecondary,
                      tooltip: 'Tirar da lista',
                      onPressed: onRemove,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Wrap: em tela estreita ou com fonte grande, o preço desce
              // para a linha de baixo em vez de estourar.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _QuantityStepper(
                    quantity: item.quantity,
                    unit: item.product.unit,
                    picked: _picked,
                    onIncrement: _picked ? null : onIncrement,
                    onDecrement: _picked ? null : onDecrement,
                  ),
                  _PriceButton(item: item, onPressed: onTogglePicked),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.unit,
    required this.picked,
    this.onIncrement,
    this.onDecrement,
  });

  final double quantity;
  final String unit;
  final bool picked;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    if (picked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          QuantityFormatter.withUnit(quantity, unit),
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconButton(
            icon: Icons.remove_circle_outline,
            color: AppColors.textSecondary,
            onPressed: quantity > 0 ? onDecrement : null,
            tooltip: 'Diminuir',
          ),
          // Flexible: com fonte grande do sistema o número encolhe
          // em vez de empurrar os botões para fora do card.
          Flexible(
            child: Text(
              QuantityFormatter.withUnit(quantity, unit),
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          AppIconButton(
            icon: Icons.add_circle_outline,
            color: AppColors.primaryStrong,
            onPressed: onIncrement,
            tooltip: 'Aumentar',
          ),
        ],
      ),
    );
  }
}

class _PriceButton extends StatelessWidget {
  const _PriceButton({required this.item, required this.onPressed});

  final ProjectedItem item;
  final VoidCallback onPressed;

  String get _label {
    if (!item.hasPrice) return 'Informar preço';
    final prefix = item.picked ? 'Paguei' : 'Previsto';
    return '$prefix ${CurrencyFormatter.formatBrl(item.totalPrice)}';
  }

  IconData get _icon {
    if (!item.hasPrice) return Icons.help_outline;
    return item.picked ? Icons.check_circle_outline : Icons.trending_flat;
  }

  @override
  Widget build(BuildContext context) {
    final picked = item.picked;
    final color = picked
        ? AppColors.textPrimary
        : (item.hasPrice ? AppColors.primaryStrong : AppColors.warning);
    final background = picked
        ? AppColors.surface.withValues(alpha: 0.35)
        : color.withValues(alpha: 0.1);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
