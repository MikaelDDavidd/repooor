import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/presentation/shared/widgets/item_pick_dialog.dart';

void main() {
  Future<ItemPickResult?> openDialog(
    WidgetTester tester, {
    double initialQuantity = 2,
    double? initialUnitPrice,
    String unit = 'kg',
  }) async {
    ItemPickResult? result;
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ItemPickDialog.show(
                  context,
                  productName: 'Arroz Tipo 1',
                  unit: unit,
                  initialQuantity: initialQuantity,
                  initialUnitPrice: initialUnitPrice,
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('shows the product name and the initial quantity', (
    tester,
  ) async {
    await openDialog(tester);

    expect(find.text('Arroz Tipo 1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
  });

  testWidgets('increments and decrements the quantity', (tester) async {
    await openDialog(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('never goes below zero', (tester) async {
    await openDialog(tester, initialQuantity: 1);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('price is optional and subtotal shows a dash without it', (
    tester,
  ) async {
    await openDialog(tester);

    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('computes the subtotal live as the price is typed', (
    tester,
  ) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField), '10,50');
    await tester.pumpAndSettle();

    expect(find.textContaining('21,00'), findsOneWidget);
  });

  testWidgets('recomputes the subtotal when the quantity changes', (
    tester,
  ) async {
    await openDialog(tester, initialUnitPrice: 5);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.textContaining('15,00'), findsOneWidget);
  });

  testWidgets('returns quantity and price on confirm', (tester) async {
    ItemPickResult? captured;
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                captured = await ItemPickDialog.show(
                  context,
                  productName: 'Arroz',
                  unit: 'kg',
                  initialQuantity: 2,
                  initialUnitPrice: 28.9,
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Peguei'));
    await tester.pumpAndSettle();

    expect(captured!.quantity, 3);
    expect(captured!.unitPrice, 28.9);
  });

  testWidgets('returns null price when the field is left empty', (
    tester,
  ) async {
    ItemPickResult? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                captured = await ItemPickDialog.show(
                  context,
                  productName: 'Arroz',
                  unit: 'kg',
                  initialQuantity: 1,
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Peguei'));
    await tester.pumpAndSettle();

    expect(captured!.unitPrice, isNull);
    expect(captured!.quantity, 1);
  });

  testWidgets('cancel returns nothing', (tester) async {
    final result = await openDialog(tester);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('cannot confirm with zero quantity', (tester) async {
    await openDialog(tester, initialQuantity: 0);

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Peguei'),
    );

    expect(button.onPressed, isNull);
  });

  testWidgets('does not overflow on a narrow screen', (tester) async {
    await openDialog(tester);
    expect(tester.takeException(), isNull);
  });
}
