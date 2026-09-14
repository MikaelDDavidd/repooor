import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/core/theme/app_colors.dart';

double _channel(double value) {
  final c = value / 255;
  return c <= 0.03928
      ? c / 12.92
      : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

double luminance(Color color) {
  return 0.2126 * _channel(color.r * 255) +
      0.7152 * _channel(color.g * 255) +
      0.0722 * _channel(color.b * 255);
}

double contrast(Color a, Color b) {
  final la = luminance(a);
  final lb = luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

Color flatten(Color foreground, Color background) {
  final a = foreground.a;
  return Color.fromARGB(
    255,
    ((foreground.r * a + background.r * (1 - a)) * 255).round(),
    ((foreground.g * a + background.g * (1 - a)) * 255).round(),
    ((foreground.b * a + background.b * (1 - a)) * 255).round(),
  );
}

void main() {
  const white = AppColors.background;
  const grey = AppColors.backgroundSecondary;
  final greenTint = flatten(AppColors.primaryLight, white);

  group('texto precisa de 4.5:1 (WCAG AA)', () {
    test('texto do botão primário sobre o fundo do botão', () {
      expect(
        contrast(AppColors.onPrimary, AppColors.primaryStrong),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('verde de destaque sobre branco', () {
      expect(
        contrast(AppColors.primaryStrong, white),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('verde de destaque sobre o fundo cinza', () {
      expect(
        contrast(AppColors.primaryStrong, grey),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('verde de destaque sobre o chip verde-claro', () {
      expect(
        contrast(AppColors.primaryStrong, greenTint),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('texto secundário sobre os dois fundos', () {
      expect(
        contrast(AppColors.textSecondary, white),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(AppColors.textSecondary, grey),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('texto principal sobre branco', () {
      expect(contrast(AppColors.textPrimary, white), greaterThanOrEqualTo(4.5));
    });

    test('aviso e erro sobre branco', () {
      expect(contrast(AppColors.warning, white), greaterThanOrEqualTo(4.5));
      expect(contrast(AppColors.error, white), greaterThanOrEqualTo(4.5));
    });

    test('texto escuro sobre o card verde de item pego', () {
      expect(
        contrast(AppColors.textPrimary, AppColors.primary),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('controles e ícones precisam de 3:1', () {
    test('contorno de input sobre branco', () {
      expect(
        contrast(AppColors.borderStrong, white),
        greaterThanOrEqualTo(3.0),
      );
    });

    test('ícone do check verde sobre círculo branco', () {
      expect(
        contrast(AppColors.primaryStrong, white),
        greaterThanOrEqualTo(3.0),
      );
    });
  });

  group('o verde vibrante segue sendo cor de preenchimento', () {
    test('não serve para texto branco, por isso não é usado assim', () {
      expect(contrast(AppColors.onPrimary, AppColors.primary), lessThan(4.5));
    });

    test('primary e primaryStrong compartilham o mesmo matiz', () {
      final a = HSVColor.fromColor(AppColors.primary);
      final b = HSVColor.fromColor(AppColors.primaryStrong);
      expect((a.hue - b.hue).abs(), lessThan(6));
    });
  });
}
