import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/pantry_item.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/repositories/pantry_repository.dart';
import 'package:repooor/domain/repositories/product_repository.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/projection/build_market_projection.dart';
import 'package:repooor/domain/usecases/projection/get_last_prices.dart';

class _MockPantryRepository extends Mock implements PantryRepository {}

class _MockProductRepository extends Mock implements ProductRepository {}

class _MockPurchaseRepository extends Mock implements PurchaseRepository {}

const arroz = Product(id: 'arroz', name: 'Arroz', categoryId: 'c1', unit: 'kg');
const feijao = Product(
  id: 'feijao',
  name: 'Feijao',
  categoryId: 'c1',
  unit: 'kg',
);
const cafe = Product(id: 'cafe', name: 'Cafe', categoryId: 'c2', unit: 'un');

PantryItem pantry(String productId, double current, double ideal) => PantryItem(
  id: 'pi-$productId',
  productId: productId,
  currentQuantity: current,
  idealQuantity: ideal,
);

void main() {
  late _MockPantryRepository pantryRepo;
  late _MockProductRepository productRepo;
  late _MockPurchaseRepository purchaseRepo;
  late BuildMarketProjection usecase;

  setUp(() {
    pantryRepo = _MockPantryRepository();
    productRepo = _MockProductRepository();
    purchaseRepo = _MockPurchaseRepository();
    when(
      () => productRepo.getAll(),
    ).thenAnswer((_) async => [arroz, feijao, cafe]);
    when(() => purchaseRepo.getAll()).thenAnswer((_) async => []);
    usecase = BuildMarketProjection(
      pantryRepo,
      productRepo,
      GetLastPrices(purchaseRepo),
    );
  });

  test('includes only items below the ideal quantity', () async {
    when(() => pantryRepo.getAll()).thenAnswer(
      (_) async => [
        pantry('arroz', 1, 5),
        pantry('feijao', 3, 3),
        pantry('cafe', 4, 2),
      ],
    );

    final projection = await usecase();

    expect(projection.totalItems, 1);
    expect(projection.items.single.product.id, 'arroz');
  });

  test('projects the exact deficit as quantity', () async {
    when(
      () => pantryRepo.getAll(),
    ).thenAnswer((_) async => [pantry('arroz', 1.5, 5)]);

    final projection = await usecase();

    expect(projection.items.single.quantity, 3.5);
    expect(projection.items.single.currentQuantity, 1.5);
    expect(projection.items.single.idealQuantity, 5);
  });

  test('fills the last registered price and its date', () async {
    when(
      () => pantryRepo.getAll(),
    ).thenAnswer((_) async => [pantry('arroz', 0, 2)]);
    when(() => purchaseRepo.getAll()).thenAnswer(
      (_) async => [
        Purchase(
          id: 'p1',
          date: DateTime(2026, 6, 10),
          type: PurchaseType.main,
          items: const [
            PurchaseItem(
              id: 'i1',
              purchaseId: 'p1',
              productId: 'arroz',
              quantity: 1,
              unitPrice: 28.9,
            ),
          ],
        ),
      ],
    );

    final item = (await usecase()).items.single;

    expect(item.unitPrice, 28.9);
    expect(item.lastPriceDate, DateTime(2026, 6, 10));
    expect(item.totalPrice, closeTo(57.8, 0.001));
  });

  test('leaves price null when the product was never bought', () async {
    when(
      () => pantryRepo.getAll(),
    ).thenAnswer((_) async => [pantry('arroz', 0, 2)]);

    final projection = await usecase();

    expect(projection.items.single.unitPrice, isNull);
    expect(projection.items.single.hasPrice, isFalse);
    expect(projection.isPartial, isTrue);
    expect(projection.itemsWithoutPrice, 1);
  });

  test('skips pantry items whose product no longer exists', () async {
    when(
      () => pantryRepo.getAll(),
    ).thenAnswer((_) async => [pantry('fantasma', 0, 5)]);

    expect((await usecase()).isEmpty, isTrue);
  });

  test('sorts items alphabetically by product name', () async {
    when(() => pantryRepo.getAll()).thenAnswer(
      (_) async => [
        pantry('feijao', 0, 1),
        pantry('arroz', 0, 1),
        pantry('cafe', 0, 1),
      ],
    );

    final names = (await usecase()).items.map((i) => i.product.name).toList();

    expect(names, ['Arroz', 'Cafe', 'Feijao']);
  });

  test('estimated total sums only items that have a price', () async {
    when(
      () => pantryRepo.getAll(),
    ).thenAnswer((_) async => [pantry('arroz', 0, 2), pantry('feijao', 0, 1)]);
    when(() => purchaseRepo.getAll()).thenAnswer(
      (_) async => [
        Purchase(
          id: 'p1',
          date: DateTime(2026, 6, 10),
          type: PurchaseType.main,
          items: const [
            PurchaseItem(
              id: 'i1',
              purchaseId: 'p1',
              productId: 'arroz',
              quantity: 1,
              unitPrice: 10,
            ),
          ],
        ),
      ],
    );

    final projection = await usecase();

    expect(projection.estimatedTotal, 20);
    expect(projection.isPartial, isTrue);
  });

  test('returns empty projection when pantry is fully stocked', () async {
    when(
      () => pantryRepo.getAll(),
    ).thenAnswer((_) async => [pantry('arroz', 5, 5)]);

    expect((await usecase()).isEmpty, isTrue);
  });
}
