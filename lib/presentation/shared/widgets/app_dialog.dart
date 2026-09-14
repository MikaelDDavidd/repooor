import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum AppDialogTone { neutral, primary, destructive }

class AppDialogAction {
  const AppDialogAction({
    required this.label,
    this.onPressed,
    this.tone = AppDialogTone.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppDialogTone tone;
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.tone = AppDialogTone.primary,
    this.content,
    this.primaryAction,
    this.secondaryAction,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final AppDialogTone tone;
  final Widget? content;
  final AppDialogAction? primaryAction;
  final AppDialogAction? secondaryAction;

  static Color colorOf(AppDialogTone tone) => switch (tone) {
    AppDialogTone.neutral => AppColors.textSecondary,
    AppDialogTone.primary => AppColors.primaryStrong,
    AppDialogTone.destructive => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    final accent = colorOf(tone);

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (icon != null) ...[
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accent, size: 28),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              ],
              if (content != null) ...[const SizedBox(height: 20), content!],
              if (primaryAction != null || secondaryAction != null) ...[
                const SizedBox(height: 24),
                if (primaryAction != null) _primaryButton(primaryAction!),
                if (secondaryAction != null) ...[
                  const SizedBox(height: 8),
                  _secondaryButton(secondaryAction!),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryButton(AppDialogAction action) {
    return ElevatedButton(
      onPressed: action.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorOf(action.tone),
        foregroundColor: AppColors.onPrimary,
      ),
      child: Text(action.label),
    );
  }

  Widget _secondaryButton(AppDialogAction action) {
    return TextButton(
      onPressed: action.onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        minimumSize: const Size.fromHeight(48),
      ),
      child: Text(action.label),
    );
  }
}
