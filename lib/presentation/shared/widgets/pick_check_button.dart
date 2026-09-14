import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PickCheckButton extends StatelessWidget {
  const PickCheckButton({
    super.key,
    required this.picked,
    required this.onPressed,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  final bool picked;
  final VoidCallback onPressed;
  final IconData fallbackIcon;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: picked,
      label: picked ? 'Item pego' : 'Marcar como pego',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: picked
                ? AppColors.surface
                : fallbackColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: picked
                ? null
                : Border.all(color: fallbackColor.withValues(alpha: 0.35)),
          ),
          child: Icon(
            picked ? Icons.check : fallbackIcon,
            color: picked ? AppColors.primaryStrong : fallbackColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}
