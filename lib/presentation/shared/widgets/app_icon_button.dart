import 'package:flutter/material.dart';

/// Botão de ícone com alvo de toque de 44pt, o mínimo do Apple HIG
/// (48dp no Material). O `visualDensity: compact` do IconButton entrega
/// cerca de 32pt e faz o dedo errar.
///
/// O ícone continua pequeno; só a área sensível ao toque cresce.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
    this.iconSize = 20,
  });

  static const minTouchTarget = 44.0;

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize),
      color: color,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: minTouchTarget,
        minHeight: minTouchTarget,
      ),
    );
  }
}
