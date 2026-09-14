import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/currency_formatter.dart';

class PriceField extends StatelessWidget {
  const PriceField({
    super.key,
    required this.controller,
    this.label = 'Preço unitário',
    this.helperText = 'Opcional',
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;

  static double? parse(TextEditingController controller) =>
      CurrencyFormatter.parseBrlInput(controller.text);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixText: r'R$ ',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
    );
  }
}
