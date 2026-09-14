import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/projection/market_projection.dart';
import 'package:repooor/domain/entities/projection/projected_item.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/projection/create_purchase_from_projection.dart';

class _MockPurchaseRepository extends Mock implements PurchaseRepository {}

class _MockPurchaseItemRepository extends Mock
    implements PurchaseItemRepository {}

class _FakePurchase extends Fake implements Purchase {}

class _FakePurchaseItem extends Fake implements PurchaseItem {}

const arroz = Product(id: 'arroz', name: 'Arroz', categoryId: 'c1', unit: 'kg');
const cafe = Product(id: 'cafe', name: 'Cafe', categoryId: 'c2', unit: 'un');

MarketProjection projection() => const MarketProjection(
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
    registerFallbackValue(_FakePurchase());
    registerFallbackValue(_FakePurchaseItem());
  });

  late _MockPurchaseRepository purchaseRepo;
  late _MockPurchaseItemRepository itemRepo;
  late CreatePurchaseFromProjection usecase;
  late List<Purchase> createdPurchases;
  late List<PurchaseItem> createdItems;

  setUp(() {
    purchaseRepo = _MockPurchaseRepository();
    itemRepo = _MockPurchaseItemRepository();
    createdPurchases = [];
    createdItems = [];
    when(() => purchaseRepo.create(any())).thenAnswer((invocation) async {
      createdPurchases.add(invocation.positionalArguments.first as Purchase);
    });
    when(() => itemRepo.addItem(any())).thenAnswer((invocation) async {
      createdItems.add(invocation.positionalArguments.first as PurchaseItem);
    });
    usecase = CreatePurchaseFromProjection(purchaseRepo, itemRepo);
  });

  test('creates the purchase with planned status', () async {
    await usecase(projection(), type: PurchaseType.main);

    expect(createdPurchases.single.status, PurchaseStatus.planned);
    expect(createdPurchases.single.isPlanned, isTrue);
    expect(createdPurchases.single.type, PurchaseType.main);
  });

  test('adds one item per projected item', () async {
    await usecase(projection(), type: PurchaseType.main);

    expect(createdItems, hasLength(2));
    expect(
      createdItems.map((i) => i.productId),
      containsAll(['arroz', 'cafe']),
    );
  });

  test('stores the projection in both current and planned fields', () async {
    await usecase(projection(), type: PurchaseType.main);

    final arrozItem = createdItems.firstWhere((i) => i.productId == 'arroz');
    expect(arrozItem.quantity, 2);
    expect(arrozItem.unitPrice, 28.9);
    expect(arrozItem.plannedQuantity, 2);
    expect(arrozItem.plannedUnitPrice, 28.9);
    expect(arrozItem.plannedTotalPrice, closeTo(57.8, 0.001));
  });

  test('keeps planned price null for items without an estimate', () async {
    await usecase(projection(), type: PurchaseType.main);

    final cafeItem = createdItems.firstWhere((i) => i.productId == 'cafe');
    expect(cafeItem.plannedUnitPrice, isNull);
    expect(cafeItem.plannedQuantity, 1);
    expect(cafeItem.plannedTotalPrice, isNull);
  });

  test('links every item to the created purchase', () async {
    final purchaseId = await usecase(projection(), type: PurchaseType.midMonth);

    expect(purchaseId, createdPurchases.single.id);
    for (final item in createdItems) {
      expect(item.purchaseId, purchaseId);
    }
  });

  test('uses the given date when provided', () async {
    await usecase(
      projection(),
      type: PurchaseType.main,
      date: DateTime(2026, 7, 24),
    );

    expect(createdPurchases.single.date, DateTime(2026, 7, 24));
  });

  test('throws when the projection has no items', () async {
    expect(
      () => usecase(const MarketProjection(), type: PurchaseType.main),
      throwsA(isA<StateError>()),
    );
  });
}
