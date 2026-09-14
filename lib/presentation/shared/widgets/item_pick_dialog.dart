import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../utils/quantity_formatter.dart';
import 'app_dialog.dart';
import 'price_field.dart';

class ItemPickResult {
  const ItemPickResult({required this.quantity, this.unitPrice});

  final double quantity;
  final double? unitPrice;
}

class ItemPickDialog extends StatefulWidget {
  const ItemPickDialog({
    super.key,
    required this.productName,
    required this.unit,
    required this.initialQuantity,
    this.initialUnitPrice,
    this.confirmLabel = 'Peguei',
    this.title,
  });

  final String productName;
  final String unit;
  final double initialQuantity;
  final double? initialUnitPrice;
  final String confirmLabel;
  final String? title;

  static Future<ItemPickResult?> show(
    BuildContext context, {
    required String productName,
    required String unit,
    required double initialQuantity,
    double? initialUnitPrice,
    String confirmLabel = 'Peguei',
    String? title,
  }) {
    return showDialog<ItemPickResult>(
      context: context,
      builder: (_) => ItemPickDialog(
        productName: productName,
        unit: unit,
        initialQuantity: initialQuantity,
        initialUnitPrice: initialUnitPrice,
        confirmLabel: confirmLabel,
        title: title,
      ),
    );
  }

  @override
  State<ItemPickDialog> createState() => _ItemPickDialogState();
}

class _ItemPickDialogState extends State<ItemPickDialog> {
  late double _quantity;
  late final TextEditingController _priceController;
  double? _unitPrice;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _unitPrice = widget.initialUnitPrice;
    _priceController = TextEditingController(
      text: _unitPrice == null
          ? ''
          : _unitPrice!.toStringAsFixed(2).replaceAll('.', ','),
    );
    _priceController.addListener(_onPriceChanged);
  }

  @override
  void dispose() {
    _priceController.removeListener(_onPriceChanged);
    _priceController.dispose();
    super.dispose();
  }

  void _onPriceChanged() {
    setState(() => _unitPrice = PriceField.parse(_priceController));
  }

  void _changeQuantity(double delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(0.0, double.infinity).toDouble();
    });
  }

  double? get _subtotal => _unitPrice == null ? null : _unitPrice! * _quantity;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: widget.title ?? widget.productName,
      message: widget.title == null ? null : widget.productName,
      icon: Icons.shopping_basket_outlined,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuantityRow(
            quantity: _quantity,
            unit: widget.unit,
            onDecrement: () => _changeQuantity(-1),
            onIncrement: () => _changeQuantity(1),
          ),
          const SizedBox(height: 20),
          PriceField(controller: _priceController, helperText: 'Opcional'),
          const SizedBox(height: 16),
          _SubtotalRow(subtotal: _subtotal),
        ],
      ),
      primaryAction: AppDialogAction(
        label: widget.confirmLabel,
        onPressed: _quantity <= 0
            ? null
            : () => Navigator.of(
                context,
              ).pop(ItemPickResult(quantity: _quantity, unitPrice: _unitPrice)),
      ),
      secondaryAction: AppDialogAction(
        label: 'Cancelar',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    required this.quantity,
    required this.unit,
    required this.onDecrement,
    required this.onIncrement,
  });

  final double quantity;
  final String unit;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StepButton(
          icon: Icons.remove,
          onPressed: quantity > 0 ? onDecrement : null,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                QuantityFormatter.format(quantity),
                style: AppTextStyles.heading1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(unit, style: AppTextStyles.caption),
            ],
          ),
        ),
        _StepButton(icon: Icons.add, onPressed: onIncrement),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled ? AppColors.primaryStrong : AppColors.border;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryLight : Colors.transparent,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _SubtotalRow extends StatelessWidget {
  const _SubtotalRow({required this.subtotal});

  final double? subtotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text('Subtotal', style: AppTextStyles.bodySecondary)),
          const SizedBox(width: 8),
          Text(
            CurrencyFormatter.formatBrl(subtotal),
            style: AppTextStyles.body.copyWith(
              color: subtotal == null
                  ? AppColors.textSecondary
                  : AppColors.primaryStrong,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
