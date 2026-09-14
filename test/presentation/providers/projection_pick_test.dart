import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/core/di/projection_providers.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/projection/market_projection.dart';
import 'package:repooor/domain/entities/projection/projected_item.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/usecases/projection/build_market_projection.dart';
import 'package:repooor/domain/usecases/projection/create_purchase_from_projection.dart';
import 'package:repooor/presentation/providers/projection_providers.dart';

class _MockBuild extends Mock implements BuildMarketProjection {}

class _MockCreate extends Mock implements CreatePurchaseFromProjection {}

class _FakeProjection extends Fake implements MarketProjection {}

const arroz = Product(id: 'arroz', name: 'Arroz', categoryId: 'c1', unit: 'kg');
const cafe = Product(id: 'cafe', name: 'Cafe', categoryId: 'c1', unit: 'un');

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
      unitPrice: 15,
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
    when(() => build.call()).thenAnswer((_) async => seed());
    when(
      () => create.call(any(), type: any(named: 'type')),
    ).thenAnswer((_) async => 'compra-1');
  });

  Future<ProviderContainer> loaded() async {
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

  test('items start unpicked', () async {
    final container = await loaded();
    final projection = container.read(marketProjectionProvider).value!;

    expect(projection.pickedCount, 0);
    expect(projection.pickedTotal, 0);
    expect(projection.isFullyPicked, isFalse);
  });

  test('pick marks the item and records the confirmed values', () async {
    final container = await loaded();

    container
        .read(marketProjectionProvider.notifier)
        .pick(0, quantity: 3, unitPrice: 31.5);

    final item = container.read(marketProjectionProvider).value!.items.first;
    expect(item.picked, isTrue);
    expect(item.quantity, 3);
    expect(item.unitPrice, 31.5);
  });

  test('pickedTotal counts only what is in the cart', () async {
    final container = await loaded();

    container
        .read(marketProjectionProvider.notifier)
        .pick(0, quantity: 2, unitPrice: 30);

    final projection = container.read(marketProjectionProvider).value!;
    expect(projection.pickedCount, 1);
    expect(projection.pickedTotal, 60);
    expect(projection.estimatedTotal, 75);
  });

  test('pick without price keeps the price empty', () async {
    final container = await loaded();

    container.read(marketProjectionProvider.notifier).pick(0, quantity: 2);

    final item = container.read(marketProjectionProvider).value!.items.first;
    expect(item.picked, isTrue);
    expect(item.unitPrice, isNull);
  });

  test('unpick returns the item to the pending list', () async {
    final container = await loaded();
    final notifier = container.read(marketProjectionProvider.notifier);
    notifier.pick(0, quantity: 3, unitPrice: 31.5);

    notifier.unpick(0);

    final item = container.read(marketProjectionProvider).value!.items.first;
    expect(item.picked, isFalse);
    expect(item.quantity, 3);
    expect(item.unitPrice, 31.5);
  });

  test('isFullyPicked when everything is in the cart', () async {
    final container = await loaded();
    final notifier = container.read(marketProjectionProvider.notifier);

    notifier.pick(0, quantity: 2, unitPrice: 28.9);
    notifier.pick(1, quantity: 1, unitPrice: 15);

    expect(
      container.read(marketProjectionProvider).value!.isFullyPicked,
      isTrue,
    );
  });

  test('setQuantity replaces the quantity directly', () async {
    final container = await loaded();

    container.read(marketProjectionProvider.notifier).setQuantity(0, 7.5);

    expect(
      container.read(marketProjectionProvider).value!.items.first.quantity,
      7.5,
    );
  });

  test('setQuantity never accepts a negative value', () async {
    final container = await loaded();

    container.read(marketProjectionProvider.notifier).setQuantity(0, -5);

    expect(
      container.read(marketProjectionProvider).value!.items.first.quantity,
      0,
    );
  });

  test('carries the picked flag into the created purchase', () async {
    final container = await loaded();
    final notifier = container.read(marketProjectionProvider.notifier);
    notifier.pick(0, quantity: 2, unitPrice: 28.9);

    await notifier.confirm(PurchaseType.main);

    final captured =
        verify(
              () => create.call(captureAny(), type: any(named: 'type')),
            ).captured.single
            as MarketProjection;
    expect(captured.items.first.picked, isTrue);
    expect(captured.items[1].picked, isFalse);
  });

  test('purchase entity exposes the same cart aggregates', () {
    final purchase = Purchase(
      id: 'p1',
      date: DateTime(2026, 7, 24),
      type: PurchaseType.main,
      status: PurchaseStatus.planned,
      items: const [
        PurchaseItem(
          id: 'i1',
          purchaseId: 'p1',
          productId: 'arroz',
          quantity: 2,
          unitPrice: 30,
          picked: true,
        ),
        PurchaseItem(
          id: 'i2',
          purchaseId: 'p1',
          productId: 'cafe',
          quantity: 1,
          unitPrice: 15,
        ),
      ],
    );

    expect(purchase.pickedCount, 1);
    expect(purchase.pickedTotal, 60);
    expect(purchase.isFullyPicked, isFalse);
  });

  test('ignores pick and unpick on an invalid index', () async {
    final container = await loaded();
    final notifier = container.read(marketProjectionProvider.notifier);

    notifier.pick(99, quantity: 1);
    notifier.unpick(99);
    notifier.setQuantity(99, 5);

    expect(container.read(marketProjectionProvider).value!.pickedCount, 0);
  });
}
