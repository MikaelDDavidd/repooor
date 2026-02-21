import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Análise', style: AppTextStyles.heading1),
      ),
    );
  }
}
