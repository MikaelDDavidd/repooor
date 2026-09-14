import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/core/di/projection_providers.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/projection/market_projection.dart';
import 'package:repooor/domain/entities/projection/projected_item.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/usecases/projection/build_market_projection.dart';
import 'package:repooor/domain/usecases/projection/create_purchase_from_projection.dart';
import 'package:repooor/presentation/providers/projection_providers.dart';

class _MockBuildMarketProjection extends Mock
    implements BuildMarketProjection {}

class _MockCreatePurchaseFromProjection extends Mock
    implements CreatePurchaseFromProjection {}

class _FakeMarketProjection extends Fake implements MarketProjection {}

const arroz = Product(id: 'arroz', name: 'Arroz', categoryId: 'c1', unit: 'kg');
const cafe = Product(id: 'cafe', name: 'Cafe', categoryId: 'c2', unit: 'un');

MarketProjection seed() => const MarketProjection(
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
    when(() => build.call()).thenAnswer((_) async => seed());
    when(
      () => create.call(any(), type: any(named: 'type')),
    ).thenAnswer((_) async => 'compra-1');
  });

  Future<ProviderContainer> loadedContainer() async {
    final container = ProviderContainer(
      overrides: [
        buildMarketProjectionProvider.overrideWithValue(build),
        createPurchaseFromProjectionProvider.overrideWithValue(create),
      ],
    );
    addTearDown(container.dispose);
    await container.read(marketProjectionProvider.future);
    return container;
  }

  test('loads the projection from the usecase', () async {
    final container = await loadedContainer();

    expect(container.read(marketProjectionProvider).value!.totalItems, 2);
  });

  test('increment raises the quantity by one step', () async {
    final container = await loadedContainer();

    container.read(marketProjectionProvider.notifier).increment(0);

    expect(
      container.read(marketProjectionProvider).value!.items.first.quantity,
      3,
    );
  });

  test('decrement lowers the quantity by one step', () async {
    final container = await loadedContainer();

    container.read(marketProjectionProvider.notifier).decrement(0);

    expect(
      container.read(marketProjectionProvider).value!.items.first.quantity,
      1,
    );
  });

  test('decrement never goes below zero', () async {
    final container = await loadedContainer();
    final notifier = container.read(marketProjectionProvider.notifier);

    notifier.decrement(1);
    notifier.decrement(1);

    expect(
      container.read(marketProjectionProvider).value!.items[1].quantity,
      0,
    );
  });

  test('setUnitPrice updates the estimate and the total', () async {
    final container = await loadedContainer();

    container.read(marketProjectionProvider.notifier).setUnitPrice(1, 15.5);

    final projection = container.read(marketProjectionProvider).value!;
    expect(projection.items[1].unitPrice, 15.5);
    expect(projection.estimatedTotal, closeTo(2 * 28.9 + 15.5, 0.001));
    expect(projection.isPartial, isFalse);
  });

  test('setUnitPrice with null clears the estimate', () async {
    final container = await loadedContainer();

    container.read(marketProjectionProvider.notifier).setUnitPrice(0, null);

    final projection = container.read(marketProjectionProvider).value!;
    expect(projection.items.first.unitPrice, isNull);
    expect(projection.estimatedTotal, 0);
  });

  test('removeItem drops the item from the list', () async {
    final container = await loadedContainer();

    container.read(marketProjectionProvider.notifier).removeItem(0);

    final projection = container.read(marketProjectionProvider).value!;
    expect(projection.totalItems, 1);
    expect(projection.items.single.product.id, 'cafe');
  });

  test('confirm sends the adjusted projection to the usecase', () async {
    final container = await loadedContainer();
    final notifier = container.read(marketProjectionProvider.notifier);
    notifier.increment(0);
    notifier.setUnitPrice(1, 10);

    final purchaseId = await notifier.confirm(PurchaseType.midMonth);

    final captured =
        verify(
              () => create.call(captureAny(), type: PurchaseType.midMonth),
            ).captured.single
            as MarketProjection;
    expect(purchaseId, 'compra-1');
    expect(captured.items.first.quantity, 3);
    expect(captured.items[1].unitPrice, 10);
  });

  test('confirm drops items zeroed out by the user', () async {
    final container = await loadedContainer();
    final notifier = container.read(marketProjectionProvider.notifier);
    notifier.decrement(1);

    await notifier.confirm(PurchaseType.main);

    final captured =
        verify(
              () => create.call(captureAny(), type: any(named: 'type')),
            ).captured.single
            as MarketProjection;
    expect(captured.totalItems, 1);
    expect(captured.items.single.product.id, 'arroz');
  });

  test('ignores actions on an out of range index', () async {
    final container = await loadedContainer();
    final notifier = container.read(marketProjectionProvider.notifier);

    notifier.increment(99);
    notifier.setUnitPrice(99, 5);
    notifier.removeItem(99);

    expect(container.read(marketProjectionProvider).value!.totalItems, 2);
  });
}
