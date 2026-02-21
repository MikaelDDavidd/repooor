import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Compras', style: AppTextStyles.heading1),
      ),
    );
  }
}
