import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FirstUseBanner extends StatelessWidget {
  const FirstUseBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.lightbulb, color: AppColors.onPrimary, size: 24),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comece por aqui!',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text('Cadastre seus primeiros produtos', style: AppTextStyles.caption),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ElevatedButton(
            onPressed: () => context.push('/products'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(
              'Cadastrar produtos',
              style: AppTextStyles.button.copyWith(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
