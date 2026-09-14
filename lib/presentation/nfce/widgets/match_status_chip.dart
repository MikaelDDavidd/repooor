import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/nfce/match_type.dart';

class MatchStatusChip extends StatelessWidget {
  const MatchStatusChip({super.key, required this.type});

  final MatchType type;

  ({Color background, Color foreground, String label, IconData icon})
  get _style {
    return switch (type) {
      MatchType.exact => (
        background: AppColors.primaryLight,
        foreground: AppColors.primaryStrong,
        label: 'Vinculado',
        icon: Icons.check_circle,
      ),
      MatchType.fuzzyHigh => (
        background: AppColors.primaryLight,
        foreground: AppColors.primaryStrong,
        label: 'Parecido',
        icon: Icons.compare_arrows,
      ),
      MatchType.fuzzyLow => (
        background: const Color(0x1AF3603F),
        foreground: AppColors.warning,
        label: 'Sugerido',
        icon: Icons.help_outline,
      ),
      MatchType.willCreateNew => (
        background: const Color(0x1A3498DB),
        foreground: const Color(0xFF2980B9),
        label: 'Novo produto',
        icon: Icons.add_circle_outline,
      ),
      MatchType.unresolved => (
        background: const Color(0x1AD32F2F),
        foreground: AppColors.error,
        label: 'Sem produto',
        icon: Icons.error_outline,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: s.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 14, color: s.foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              s.label,
              style: AppTextStyles.caption.copyWith(
                color: s.foreground,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
