import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/presentation/pantry/widgets/pantry_add_menu.dart';

void main() {
  Future<void> pumpMenu(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: PantryAddMenu())),
      ),
    );
    await tester.pump();
  }

  testWidgets('offers both pantry actions', (tester) async {
    await pumpMenu(tester);

    expect(find.text('Adicionar à despensa'), findsOneWidget);
    expect(find.text('Projetar mercado'), findsOneWidget);
  });

  testWidgets('explains what each action does', (tester) async {
    await pumpMenu(tester);

    expect(find.text('Cadastrar um produto no seu estoque'), findsOneWidget);
    expect(
      find.text('Estimar o gasto para repor tudo que está abaixo do ideal'),
      findsOneWidget,
    );
  });

  testWidgets('uses icons instead of emoji in the labels', (tester) async {
    await pumpMenu(tester);

    expect(find.byIcon(Icons.add_shopping_cart_outlined), findsOneWidget);
    expect(find.byIcon(Icons.query_stats_outlined), findsOneWidget);
  });

  testWidgets('does not overflow on a narrow screen', (tester) async {
    await pumpMenu(tester);

    expect(tester.takeException(), isNull);
  });
}
