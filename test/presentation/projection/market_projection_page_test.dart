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
import 'package:repooor/presentation/projection/widgets/projection_summary_header.dart';
import 'package:repooor/presentation/providers/category_providers.dart';

class _MockBuildMarketProjection extends Mock
    implements BuildMarketProjection {}

class _MockCreatePurchaseFromProjection extends Mock
    implements CreatePurchaseFromProjection {}

class _FakeMarketProjection extends Fake implements MarketProjection {}

const arroz = Product(
  id: 'arroz',
  name: 'Arroz Tipo 1',
  categoryId: 'c1',
  unit: 'kg',
);
const cafe = Product(
  id: 'cafe',
  name: 'Cafe Pilao',
  categoryId: 'c1',
  unit: 'un',
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
    ProjectedItem(
      product: cafe,
      quantity: 1,
      currentQuantity: 0,
      idealQuantity: 1,
    ),
  ],
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeMarketProjection());
    registerFallbackValue(PurchaseType.main);
  });

  late _MockBuildMarketProjection build;
  late _MockCreatePurchaseFromProjection create;

  setUp(() {
    build = _MockBuildMarketProjection();
    create = _MockCreatePurchaseFromProjection();
    when(
      () => create.call(any(), type: any(named: 'type')),
    ).thenAnswer((_) async => 'compra-1');
  });

  Future<void> pumpPage(
    WidgetTester tester,
    MarketProjection projection,
  ) async {
    when(() => build.call()).thenAnswer((_) async => projection);
    tester.view.physicalSize = const Size(400, 900);
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

  Finder totalInHeader(String value) => find.descendant(
    of: find.byType(ProjectionSummaryHeader),
    matching: find.textContaining(value),
  );

  testWidgets('separa carrinho, falta pegar e previsao total', (tester) async {
    await pumpPage(tester, filled);

    expect(find.text('No carrinho'), findsOneWidget);
    expect(find.text('Falta pegar'), findsOneWidget);
    expect(find.text('Previsão total'), findsOneWidget);
    expect(find.text('0 de 2 itens'), findsOneWidget);
    expect(totalInHeader('57,80'), findsWidgets);
  });

  testWidgets('warns about items without a registered price', (tester) async {
    await pumpPage(tester, filled);

    expect(find.textContaining('sem preço'), findsOneWidget);
    expect(find.text('Informar preço'), findsOneWidget);
  });

  testWidgets('shows current versus ideal quantity per item', (tester) async {
    await pumpPage(tester, filled);

    expect(find.text('Tem 3 de 5 kg'), findsOneWidget);
    expect(find.text('Tem 0 de 1 un'), findsOneWidget);
  });

  testWidgets('increment updates quantity and total', (tester) async {
    await pumpPage(tester, filled);

    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('3 kg'), findsOneWidget);
    expect(totalInHeader('86,70'), findsWidgets);
  });

  testWidgets('decrement updates quantity and total', (tester) async {
    await pumpPage(tester, filled);

    await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('1 kg'), findsOneWidget);
    expect(find.textContaining('28,90'), findsWidgets);
  });

  testWidgets('removing an item takes it off the list', (tester) async {
    await pumpPage(tester, filled);

    await tester.tap(find.byTooltip('Tirar da lista').first);
    await tester.pumpAndSettle();

    expect(find.text('Arroz Tipo 1'), findsNothing);
    expect(find.text('0 de 1 itens'), findsOneWidget);
  });

  testWidgets('cravar sends the projection and shows item count', (
    tester,
  ) async {
    await pumpPage(tester, filled);

    expect(find.text('Cravar 2 itens'), findsOneWidget);
    await tester.tap(find.text('Cravar 2 itens'));
    await tester.pump();

    verify(() => create.call(any(), type: PurchaseType.main)).called(1);
  });

  testWidgets('shows an empty state when the pantry is stocked', (
    tester,
  ) async {
    await pumpPage(tester, const MarketProjection());

    expect(find.text('Despensa no ideal'), findsOneWidget);
    expect(find.textContaining('Cravar'), findsNothing);
  });

  testWidgets('does not overflow on a narrow screen', (tester) async {
    await pumpPage(tester, filled);
    expect(tester.takeException(), isNull);
  });
}

class _StubCategories extends CategoriesNotifier {
  @override
  Future<List<Category>> build() async => categories;
}
