import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuantityField extends StatelessWidget {
  const QuantityField({
    super.key,
    required this.controller,
    required this.label,
    this.min = 0,
    this.step = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final double min;
  final double step;
  final String? Function(String?)? validator;

  double get _value => double.tryParse(controller.text) ?? min;

  void _increment() {
    final next = _value + step;
    controller.text = _formatValue(next);
  }

  void _decrement() {
    final next = _value - step;
    if (next < min) return;
    controller.text = _formatValue(next);
  }

  String _formatValue(double v) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          keyboardType: TextInputType.number,
          validator: validator,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StepButton(
              icon: Icons.remove,
              onTap: _decrement,
            ),
            const SizedBox(width: 12),
            _StepButton(
              icon: Icons.add,
              onTap: _increment,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}
