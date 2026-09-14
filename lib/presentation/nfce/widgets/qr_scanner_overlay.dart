import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QrScannerOverlay extends StatelessWidget {
  const QrScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(size: Size.infinite, painter: _OverlayPainter()),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  static const _windowSize = 260.0;
  static const _cornerLength = 28.0;
  static const _strokeWidth = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final windowRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: _windowSize,
      height: _windowSize,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(windowRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, scrim);

    final corner = Paint()
      ..color = AppColors.primary
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawCorners(canvas, windowRect, corner);
  }

  void _drawCorners(Canvas canvas, Rect rect, Paint paint) {
    final corners = [
      [
        rect.topLeft,
        Offset(rect.left + _cornerLength, rect.top),
        Offset(rect.left, rect.top + _cornerLength),
      ],
      [
        rect.topRight,
        Offset(rect.right - _cornerLength, rect.top),
        Offset(rect.right, rect.top + _cornerLength),
      ],
      [
        rect.bottomLeft,
        Offset(rect.left + _cornerLength, rect.bottom),
        Offset(rect.left, rect.bottom - _cornerLength),
      ],
      [
        rect.bottomRight,
        Offset(rect.right - _cornerLength, rect.bottom),
        Offset(rect.right, rect.bottom - _cornerLength),
      ],
    ];
    for (final corner in corners) {
      canvas.drawLine(corner[0], corner[1], paint);
      canvas.drawLine(corner[0], corner[2], paint);
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) => false;
}
