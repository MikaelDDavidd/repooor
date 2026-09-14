import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/presentation/purchase/widgets/purchase_plan_summary.dart';

PurchaseItem item({
  required String productId,
  required double quantity,
  double? unitPrice,
  double? plannedQuantity,
  double? plannedUnitPrice,
}) => PurchaseItem(
  id: 'i-$productId',
  purchaseId: 'compra-1',
  productId: productId,
  quantity: quantity,
  unitPrice: unitPrice,
  plannedQuantity: plannedQuantity,
  plannedUnitPrice: plannedUnitPrice,
);

void main() {
  Future<void> pump(WidgetTester tester, List<PurchaseItem> items) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PurchasePlanSummary(items: items)),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders nothing when no item was planned', (tester) async {
    await pump(tester, [
      item(productId: 'arroz', quantity: 2, unitPrice: 28.9),
    ]);

    expect(find.text('Projetado x real'), findsNothing);
  });

  testWidgets('shows planned versus actual after reconciliation', (
    tester,
  ) async {
    await pump(tester, [
      item(
        productId: 'arroz',
        quantity: 2,
        unitPrice: 31.5,
        plannedQuantity: 2,
        plannedUnitPrice: 28.9,
      ),
    ]);

    expect(find.text('Projetado x real'), findsOneWidget);
    expect(find.textContaining('57,80'), findsOneWidget);
    expect(find.textContaining('63,00'), findsOneWidget);
    expect(find.text('Real'), findsOneWidget);
  });

  testWidgets('flags when the purchase went over the estimate', (tester) async {
    await pump(tester, [
      item(
        productId: 'arroz',
        quantity: 2,
        unitPrice: 31.5,
        plannedQuantity: 2,
        plannedUnitPrice: 28.9,
      ),
    ]);

    expect(find.text('Passou do previsto'), findsOneWidget);
    expect(find.textContaining('9.0%'), findsOneWidget);
  });

  testWidgets('flags when the purchase came under the estimate', (
    tester,
  ) async {
    await pump(tester, [
      item(
        productId: 'arroz',
        quantity: 2,
        unitPrice: 25.0,
        plannedQuantity: 2,
        plannedUnitPrice: 28.9,
      ),
    ]);

    expect(find.text('Abaixo do previsto'), findsOneWidget);
  });

  testWidgets('labels the total as an estimate before reconciling', (
    tester,
  ) async {
    await pump(tester, [
      item(
        productId: 'arroz',
        quantity: 2,
        unitPrice: 28.9,
        plannedQuantity: 2,
        plannedUnitPrice: 28.9,
      ),
    ]);

    expect(find.text('Estimado agora'), findsOneWidget);
    expect(find.text('Real'), findsNothing);
  });

  testWidgets(
    'ignores planned items that were not bought in the actual total',
    (tester) async {
      await pump(tester, [
        item(
          productId: 'arroz',
          quantity: 2,
          unitPrice: 28.9,
          plannedQuantity: 2,
          plannedUnitPrice: 28.9,
        ),
        item(
          productId: 'cafe',
          quantity: 0,
          plannedQuantity: 1,
          plannedUnitPrice: 15.0,
        ),
      ]);

      expect(find.textContaining('72,80'), findsOneWidget);
      expect(find.textContaining('57,80'), findsOneWidget);
      expect(find.text('Abaixo do previsto'), findsOneWidget);
    },
  );

  testWidgets('does not overflow with long values', (tester) async {
    await pump(tester, [
      item(
        productId: 'arroz',
        quantity: 100,
        unitPrice: 1234.56,
        plannedQuantity: 100,
        plannedUnitPrice: 999.99,
      ),
    ]);

    expect(tester.takeException(), isNull);
  });
}
