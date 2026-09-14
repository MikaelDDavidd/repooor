import 'package:flutter/material.dart';
import 'app_dialog.dart';
import 'slide_to_confirm.dart';

class SlideConfirmDialog extends StatelessWidget {
  const SlideConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.slideLabel,
    this.icon = Icons.lock_open_outlined,
    this.cancelLabel = 'Manter marcado',
  });

  final String title;
  final String message;
  final String slideLabel;
  final IconData icon;
  final String cancelLabel;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String slideLabel,
    IconData icon = Icons.lock_open_outlined,
    String cancelLabel = 'Manter marcado',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => SlideConfirmDialog(
        title: title,
        message: message,
        slideLabel: slideLabel,
        icon: icon,
        cancelLabel: cancelLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      message: message,
      icon: icon,
      tone: AppDialogTone.destructive,
      content: SlideToConfirm(
        label: slideLabel,
        onConfirmed: () => Navigator.of(context).pop(true),
      ),
      secondaryAction: AppDialogAction(
        label: cancelLabel,
        onPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
