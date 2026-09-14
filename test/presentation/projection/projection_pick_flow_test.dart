import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/core/di/projection_providers.dart';
import 'package:repooor/domain/entities/category.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/projection/market_projection.dart';
import 'package:repooor/domain/entities/projection/projected_item.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/usecases/projection/build_market_projection.dart';
import 'package:repooor/domain/usecases/projection/create_purchase_from_projection.dart';
import 'package:repooor/presentation/projection/market_projection_page.dart';
import 'package:repooor/presentation/providers/category_providers.dart';

class _MockBuild extends Mock implements BuildMarketProjection {}

class _MockCreate extends Mock implements CreatePurchaseFromProjection {}

class _FakeProjection extends Fake implements MarketProjection {}

const arroz = Product(
  id: 'arroz',
  name: 'Arroz Tipo 1',
  categoryId: 'c1',
  unit: 'kg',
);
const categories = [
  Category(id: 'c1', name: 'Mercearia', icon: 0xe25a, color: 0xFF53B175),
];

const filled = MarketProjection(
  items: [
    ProjectedItem(
      product: arroz,
      quantity: 2,
      currentQuantity: 3,
      idealQuantity: 5,
      unitPrice: 28.9,
    ),
  ],
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeProjection());
    registerFallbackValue(PurchaseType.main);
  });

  late _MockBuild build;
  late _MockCreate create;

  setUp(() {
    build = _MockBuild();
    create = _MockCreate();
    when(() => build.call()).thenAnswer((_) async => filled);
    when(
      () => create.call(any(), type: any(named: 'type')),
    ).thenAnswer((_) async => 'compra-1');
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          buildMarketProjectionProvider.overrideWithValue(build),
          createPurchaseFromProjectionProvider.overrideWithValue(create),
          categoriesProvider.overrideWith(() => _StubCategories()),
        ],
        child: const MaterialApp(home: MarketProjectionPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pickFirstItem(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Marcar como pego'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping the check opens the confirmation dialog', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.bySemanticsLabel('Marcar como pego'));
    await tester.pumpAndSettle();

    expect(find.text('Salvar'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);
  });

  testWidgets('tapping anywhere on the card opens the same dialog', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text('Arroz Tipo 1'));
    await tester.pumpAndSettle();

    expect(find.text('Salvar'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);
  });

  testWidgets('a picked item shows an X that asks to unmark', (tester) async {
    await pumpPage(tester);
    await pickFirstItem(tester);

    expect(find.byTooltip('Desmarcar'), findsOneWidget);
    expect(find.byTooltip('Tirar da lista'), findsNothing);

    await tester.tap(find.byTooltip('Desmarcar'));
    await tester.pumpAndSettle();

    expect(find.text('Tirar do carrinho?'), findsOneWidget);
  });

  testWidgets('confirming moves the item to the cart', (tester) async {
    await pumpPage(tester);

    await pickFirstItem(tester);

    expect(find.bySemanticsLabel('Item pego'), findsOneWidget);
    expect(find.text('1 de 1 itens'), findsOneWidget);
    expect(find.textContaining('Paguei'), findsOneWidget);
  });

  testWidgets('picked card keeps the same layout, only dimmed', (tester) async {
    await pumpPage(tester);
    await pickFirstItem(tester);

    expect(find.text('Arroz Tipo 1'), findsOneWidget);
    expect(find.text('Tem 3 de 5 kg'), findsOneWidget);

    final name = tester.widget<Text>(find.text('Arroz Tipo 1'));
    expect(name.style!.decoration, isNot(TextDecoration.lineThrough));
    expect(name.style!.color!.a, lessThan(1.0));
  });

  testWidgets('cancelling the dialog leaves the item unpicked', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.bySemanticsLabel('Marcar como pego'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Marcar como pego'), findsOneWidget);
    expect(find.text('Tem 3 de 5 kg'), findsOneWidget);
  });

  testWidgets('quantity adjusted in the dialog is kept', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.bySemanticsLabel('Marcar como pego'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('3 kg'), findsOneWidget);
  });

  testWidgets('unpicking requires the full slide', (tester) async {
    await pumpPage(tester);
    await pickFirstItem(tester);

    await tester.tap(find.bySemanticsLabel('Item pego'));
    await tester.pumpAndSettle();
    await tester.drag(find.byIcon(Icons.chevron_right), const Offset(80, 0));
    await tester.pumpAndSettle();

    expect(find.text('Tirar do carrinho?'), findsOneWidget);
    await tester.tap(find.text('Manter marcado'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Item pego'), findsOneWidget);
  });

  testWidgets('a full slide takes the item off the cart', (tester) async {
    await pumpPage(tester);
    await pickFirstItem(tester);

    await tester.tap(find.bySemanticsLabel('Item pego'));
    await tester.pumpAndSettle();
    await tester.drag(find.byIcon(Icons.chevron_right), const Offset(400, 0));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Marcar como pego'), findsOneWidget);
    expect(find.text('Tem 3 de 5 kg'), findsOneWidget);
  });

  testWidgets('steppers disappear while the item is in the cart', (
    tester,
  ) async {
    await pumpPage(tester);
    await pickFirstItem(tester);

    expect(find.byIcon(Icons.add_circle_outline), findsNothing);
    expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
    expect(find.text('2 kg'), findsOneWidget);
  });

  testWidgets('picked item keeps no overflow', (tester) async {
    await pumpPage(tester);
    await pickFirstItem(tester);

    expect(tester.takeException(), isNull);
  });
}

class _StubCategories extends CategoriesNotifier {
  @override
  Future<List<Category>> build() async => categories;
}
