import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.icon = Icons.chevron_right,
    this.accent = AppColors.error,
  });

  final String label;
  final VoidCallback onConfirmed;
  final IconData icon;
  final Color accent;

  static const height = 56.0;
  static const thumbSize = 48.0;
  static const confirmThreshold = 0.92;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  double _dragX = 0;
  bool _confirmed = false;

  double _maxDrag(double width) =>
      (width - SlideToConfirm.thumbSize - 8).clamp(1, double.infinity);

  void _onDragUpdate(DragUpdateDetails details, double width) {
    if (_confirmed) return;
    setState(() {
      _dragX = (_dragX + details.delta.dx).clamp(0.0, _maxDrag(width));
    });
  }

  void _onDragEnd(double width) {
    if (_confirmed) return;
    final progress = _dragX / _maxDrag(width);
    if (progress >= SlideToConfirm.confirmThreshold) {
      setState(() {
        _confirmed = true;
        _dragX = _maxDrag(width);
      });
      widget.onConfirmed();
      return;
    }
    setState(() => _dragX = 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final progress = (_dragX / _maxDrag(width)).clamp(0.0, 1.0);

        return Container(
          height: SlideToConfirm.height,
          decoration: BoxDecoration(
            color: widget.accent.withValues(alpha: 0.08),
            border: Border.all(color: widget.accent.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(SlideToConfirm.height / 2),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: Opacity(
                    opacity: (1 - progress).clamp(0.0, 1.0),
                    child: Text(
                      widget.label,
                      style: AppTextStyles.body.copyWith(
                        color: widget.accent,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 4 + _dragX,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) => _onDragUpdate(d, width),
                  onHorizontalDragEnd: (_) => _onDragEnd(width),
                  child: Container(
                    width: SlideToConfirm.thumbSize,
                    height: SlideToConfirm.thumbSize,
                    decoration: BoxDecoration(
                      color: widget.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _confirmed ? Icons.check : widget.icon,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
