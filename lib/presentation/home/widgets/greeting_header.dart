import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(_greeting(), style: AppTextStyles.heading1),
        const SizedBox(height: 4),
        Text('Gerencie sua despensa', style: AppTextStyles.bodySecondary),
      ],
    );
  }
}
