import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/pantry_item.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/repositories/pantry_repository.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/complete_purchase.dart';

class _MockPurchaseRepository extends Mock implements PurchaseRepository {}

class _MockPantryRepository extends Mock implements PantryRepository {}

class _FakePantryItem extends Fake implements PantryItem {}

PurchaseItem item(String productId, double qty) => PurchaseItem(
  id: 'i-$productId',
  purchaseId: 'compra-1',
  productId: productId,
  quantity: qty,
  unitPrice: 10,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePantryItem());
    registerFallbackValue(PurchaseStatus.completed);
  });

  late _MockPurchaseRepository purchaseRepo;
  late _MockPantryRepository pantryRepo;
  late CompletePurchase usecase;
  late List<PantryItem> created;
  late Map<String, double> updated;

  void givenPurchase(List<PurchaseItem> items, {PurchaseStatus? status}) {
    when(() => purchaseRepo.getById('compra-1')).thenAnswer(
      (_) async => Purchase(
        id: 'compra-1',
        date: DateTime(2026, 7, 25),
        type: PurchaseType.main,
        status: status ?? PurchaseStatus.completed,
        items: items,
      ),
    );
  }

  setUp(() {
    purchaseRepo = _MockPurchaseRepository();
    pantryRepo = _MockPantryRepository();
    created = [];
    updated = {};
    when(() => pantryRepo.getByProductId(any())).thenAnswer((_) async => null);
    when(() => pantryRepo.add(any())).thenAnswer((invocation) async {
      created.add(invocation.positionalArguments.first as PantryItem);
    });
    when(() => pantryRepo.updateQuantity(any(), any())).thenAnswer((
      invocation,
    ) async {
      updated[invocation.positionalArguments.first as String] =
          invocation.positionalArguments[1] as double;
    });
    when(
      () => purchaseRepo.updateStatus(any(), any()),
    ).thenAnswer((_) async {});
    usecase = CompletePurchase(purchaseRepo, pantryRepo);
  });

  test('cria o item na despensa quando o produto ainda não está lá', () async {
    givenPurchase([item('arroz', 2)]);

    await usecase('compra-1');

    expect(created.single.productId, 'arroz');
    expect(created.single.currentQuantity, 2);
    expect(created.single.idealQuantity, 2);
  });

  test('soma na despensa quando o produto já existe', () async {
    givenPurchase([item('arroz', 2)]);
    when(() => pantryRepo.getByProductId('arroz')).thenAnswer(
      (_) async => const PantryItem(
        id: 'pi-arroz',
        productId: 'arroz',
        currentQuantity: 3,
        idealQuantity: 5,
      ),
    );

    await usecase('compra-1');

    expect(updated['pi-arroz'], 5);
    expect(created, isEmpty);
  });

  test('nenhum item comprado é ignorado', () async {
    givenPurchase([item('arroz', 2), item('feijao', 1), item('cafe', 3)]);

    await usecase('compra-1');

    expect(
      created.map((c) => c.productId),
      containsAll(['arroz', 'feijao', 'cafe']),
    );
    expect(created, hasLength(3));
  });

  test('soma linhas repetidas do mesmo produto numa entrada só', () async {
    givenPurchase([
      item('leite', 1),
      PurchaseItem(
        id: 'i2',
        purchaseId: 'compra-1',
        productId: 'leite',
        quantity: 2,
        unitPrice: 7,
      ),
    ]);

    await usecase('compra-1');

    expect(created.single.currentQuantity, 3);
  });

  test('ignora item com quantidade zero (planejado e não comprado)', () async {
    givenPurchase([item('arroz', 2), item('cafe', 0)]);

    await usecase('compra-1');

    expect(created.map((c) => c.productId), ['arroz']);
  });

  test('marca a compra planejada como concluída', () async {
    givenPurchase([item('arroz', 2)], status: PurchaseStatus.planned);

    await usecase('compra-1');

    verify(
      () => purchaseRepo.updateStatus('compra-1', PurchaseStatus.completed),
    ).called(1);
  });

  test('não faz nada quando a compra não existe', () async {
    when(() => purchaseRepo.getById('sumiu')).thenAnswer((_) async => null);

    await usecase('sumiu');

    expect(created, isEmpty);
    expect(updated, isEmpty);
  });
}
