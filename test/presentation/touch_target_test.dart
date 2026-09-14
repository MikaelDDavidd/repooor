import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/core/theme/app_theme.dart';
import 'package:repooor/domain/entities/category.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/projection/projected_item.dart';
import 'package:repooor/presentation/projection/widgets/projected_item_card.dart';
import 'package:repooor/presentation/shared/widgets/app_icon_button.dart';
import 'package:repooor/presentation/shared/widgets/pick_check_button.dart';

const product = Product(
  id: 'p1',
  name: 'Arroz Tipo 1',
  categoryId: 'c1',
  unit: 'kg',
);

const category = Category(
  id: 'c1',
  name: 'Mercearia',
  icon: 0xe25a,
  color: 0xFF53B175,
);

void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    );
    await tester.pump();
  }

  /// Apple HIG: 44pt. Material: 48dp. Usamos 44 como piso.
  void expectMinimumTouchTargets(WidgetTester tester) {
    final buttons = find.byType(AppIconButton);
    expect(buttons, findsWidgets, reason: 'nenhum AppIconButton encontrado');
    for (final element in buttons.evaluate()) {
      final size = tester.getSize(find.byWidget(element.widget));
      expect(
        size.width,
        greaterThanOrEqualTo(AppIconButton.minTouchTarget),
        reason: 'largura do alvo de toque abaixo de 44pt',
      );
      expect(
        size.height,
        greaterThanOrEqualTo(AppIconButton.minTouchTarget),
        reason: 'altura do alvo de toque abaixo de 44pt',
      );
    }
  }

  testWidgets('botões do card da projeção têm 44pt', (tester) async {
    await pump(
      tester,
      ProjectedItemCard(
        item: const ProjectedItem(
          product: product,
          quantity: 2,
          currentQuantity: 1,
          idealQuantity: 3,
          unitPrice: 28.9,
        ),
        category: category,
        onIncrement: () {},
        onDecrement: () {},
        onRemove: () {},
        onTogglePicked: () {},
      ),
    );

    expectMinimumTouchTargets(tester);
  });

  testWidgets('AppIconButton mantém 44pt mesmo com ícone pequeno', (
    tester,
  ) async {
    await pump(
      tester,
      Center(
        child: AppIconButton(
          icon: Icons.close,
          tooltip: 'Fechar',
          iconSize: 14,
          onPressed: () {},
        ),
      ),
    );

    expectMinimumTouchTargets(tester);
  });

  testWidgets('AppIconButton desabilitado mantém o tamanho', (tester) async {
    await pump(
      tester,
      const Center(
        child: AppIconButton(icon: Icons.add, tooltip: 'Aumentar'),
      ),
    );

    expectMinimumTouchTargets(tester);
  });

  testWidgets('o check de item pego tem pelo menos 40pt', (tester) async {
    await pump(
      tester,
      Center(
        child: PickCheckButton(
          picked: false,
          onPressed: () {},
          fallbackIcon: Icons.category,
          fallbackColor: const Color(0xFF53B175),
        ),
      ),
    );

    final size = tester.getSize(find.byType(PickCheckButton));
    expect(size.width, greaterThanOrEqualTo(40));
    expect(size.height, greaterThanOrEqualTo(40));
  });

  testWidgets('todo AppIconButton tem tooltip para leitor de tela', (
    tester,
  ) async {
    await pump(
      tester,
      ProjectedItemCard(
        item: const ProjectedItem(
          product: product,
          quantity: 2,
          currentQuantity: 1,
          idealQuantity: 3,
        ),
        category: category,
        onIncrement: () {},
        onDecrement: () {},
        onRemove: () {},
        onTogglePicked: () {},
      ),
    );

    for (final element in find.byType(AppIconButton).evaluate()) {
      final button = element.widget as AppIconButton;
      expect(button.tooltip, isNotEmpty);
    }
  });
}
