import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class PantryPage extends StatelessWidget {
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Despensa', style: AppTextStyles.heading1),
      ),
    );
  }
}
