import 'package:flutter/material.dart';
import 'app_dialog.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.isDestructive = false,
    this.icon,
  });

  final String title;
  final String content;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData? icon;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDestructive = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tone = isDestructive
        ? AppDialogTone.destructive
        : AppDialogTone.primary;
    return AppDialog(
      title: title,
      message: content,
      icon:
          icon ??
          (isDestructive ? Icons.warning_amber_rounded : Icons.help_outline),
      tone: tone,
      primaryAction: AppDialogAction(
        label: confirmLabel,
        tone: tone,
        onPressed: () => Navigator.of(context).pop(true),
      ),
      secondaryAction: AppDialogAction(
        label: cancelLabel,
        onPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
