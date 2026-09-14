import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/nfce/imported_item_match.dart';
import 'package:repooor/domain/entities/nfce/match_type.dart';
import 'package:repooor/domain/entities/nfce/nfce_import_draft.dart';
import 'package:repooor/domain/entities/nfce/nfce_invoice.dart';
import 'package:repooor/domain/entities/nfce/nfce_raw_item.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/exceptions/nfce_exception.dart';
import 'package:repooor/domain/repositories/product_repository.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/nfce/ensure_matched_products.dart';
import 'package:repooor/domain/usecases/projection/reconcile_purchase_with_nfce.dart';

class _MockProductRepository extends Mock implements ProductRepository {}

class _MockPurchaseRepository extends Mock implements PurchaseRepository {}

class _MockPurchaseItemRepository extends Mock
    implements PurchaseItemRepository {}

class _FakeProduct extends Fake implements Product {}

class _FakePurchaseItem extends Fake implements PurchaseItem {}

const arroz = Product(id: 'arroz', name: 'Arroz', categoryId: 'c1', unit: 'kg');
const cafe = Product(id: 'cafe', name: 'Cafe', categoryId: 'c2', unit: 'un');

PurchaseItem plannedItem(String productId, double qty, double? price) =>
    PurchaseItem(
      id: 'item-$productId',
      purchaseId: 'compra-1',
      productId: productId,
      quantity: qty,
      unitPrice: price,
      plannedQuantity: qty,
      plannedUnitPrice: price,
    );

Purchase plannedPurchase(List<PurchaseItem> items) => Purchase(
  id: 'compra-1',
  date: DateTime(2026, 7, 24),
  type: PurchaseType.main,
  status: PurchaseStatus.planned,
  items: items,
);

ImportedItemMatch scanned(Product product, double qty, double price) =>
    ImportedItemMatch(
      source: NfceRawItem(
        rawName: product.name.toUpperCase(),
        quantity: qty,
        unitRaw: 'UN',
        unitPrice: price,
      ),
      type: MatchType.exact,
      matchedProduct: product,
      resolvedQuantity: qty,
      resolvedUnit: product.unit,
      resolvedUnitPrice: price,
    );

NfceImportDraft draftWith(List<ImportedItemMatch> matches) => NfceImportDraft(
  invoice: NfceInvoice(
    chave: '26',
    issuedAt: DateTime(2026, 7, 24),
    emitenteNome: 'Mercado',
    emitenteCnpj: '',
    uf: 'PE',
    items: const [],
  ),
  matches: matches,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeProduct());
    registerFallbackValue(_FakePurchaseItem());
    registerFallbackValue(PurchaseStatus.planned);
  });

  late _MockProductRepository productRepo;
  late _MockPurchaseRepository purchaseRepo;
  late _MockPurchaseItemRepository itemRepo;
  late ReconcilePurchaseWithNfce usecase;
  late List<PurchaseItem> updated;
  late List<PurchaseItem> added;

  setUp(() {
    productRepo = _MockProductRepository();
    purchaseRepo = _MockPurchaseRepository();
    itemRepo = _MockPurchaseItemRepository();
    updated = [];
    added = [];
    when(() => productRepo.create(any())).thenAnswer((_) async {});
    when(() => itemRepo.updateItem(any())).thenAnswer((invocation) async {
      updated.add(invocation.positionalArguments.first as PurchaseItem);
    });
    when(() => itemRepo.addItem(any())).thenAnswer((invocation) async {
      added.add(invocation.positionalArguments.first as PurchaseItem);
    });
    when(() => itemRepo.removeItem(any())).thenAnswer((_) async {});
    usecase = ReconcilePurchaseWithNfce(
      EnsureMatchedProducts(productRepo),
      purchaseRepo,
      itemRepo,
    );
  });

  test('overwrites the actual values keeping what was planned', () async {
    when(
      () => purchaseRepo.getById('compra-1'),
    ).thenAnswer((_) async => plannedPurchase([plannedItem('arroz', 2, 28.9)]));

    await usecase('compra-1', draftWith([scanned(arroz, 2, 31.5)]));

    final item = updated.single;
    expect(item.quantity, 2);
    expect(item.unitPrice, 31.5);
    expect(item.plannedQuantity, 2);
    expect(item.plannedUnitPrice, 28.9);
    expect(item.totalPrice, closeTo(63, 0.001));
    expect(item.plannedTotalPrice, closeTo(57.8, 0.001));
    expect(item.priceDifference, closeTo(5.2, 0.001));
  });

  test('adds items that were bought but not planned', () async {
    when(
      () => purchaseRepo.getById('compra-1'),
    ).thenAnswer((_) async => plannedPurchase([plannedItem('arroz', 2, 28.9)]));

    await usecase(
      'compra-1',
      draftWith([scanned(arroz, 2, 28.9), scanned(cafe, 1, 15.0)]),
    );

    expect(added.single.productId, 'cafe');
    expect(added.single.unitPrice, 15.0);
    expect(added.single.plannedQuantity, isNull);
    expect(added.single.wasPlanned, isFalse);
  });

  test(
    'zeroes planned items that were not bought but keeps the estimate',
    () async {
      when(() => purchaseRepo.getById('compra-1')).thenAnswer(
        (_) async => plannedPurchase([
          plannedItem('arroz', 2, 28.9),
          plannedItem('cafe', 1, 15.0),
        ]),
      );

      await usecase('compra-1', draftWith([scanned(arroz, 2, 28.9)]));

      final cafeItem = updated.firstWhere((i) => i.productId == 'cafe');
      expect(cafeItem.quantity, 0);
      expect(cafeItem.unitPrice, isNull);
      expect(cafeItem.totalPrice, isNull);
      expect(cafeItem.plannedQuantity, 1);
      expect(cafeItem.plannedUnitPrice, 15.0);
    },
  );

  test('records a quantity different from the planned one', () async {
    when(
      () => purchaseRepo.getById('compra-1'),
    ).thenAnswer((_) async => plannedPurchase([plannedItem('arroz', 5, 10.0)]));

    await usecase('compra-1', draftWith([scanned(arroz, 3, 10.0)]));

    expect(updated.single.quantity, 3);
    expect(updated.single.plannedQuantity, 5);
  });

  test(
    'keeps the purchase as planned so the pantry is only touched on finish',
    () async {
      when(() => purchaseRepo.getById('compra-1')).thenAnswer(
        (_) async => plannedPurchase([plannedItem('arroz', 2, 28.9)]),
      );

      await usecase('compra-1', draftWith([scanned(arroz, 2, 31.5)]));

      verifyNever(() => purchaseRepo.updateStatus(any(), any()));
    },
  );

  test('creates products for items the pantry did not know', () async {
    when(
      () => purchaseRepo.getById('compra-1'),
    ).thenAnswer((_) async => plannedPurchase([plannedItem('arroz', 2, 28.9)]));

    final newMatch = ImportedItemMatch(
      source: const NfceRawItem(
        rawName: 'DETERGENTE YPE',
        quantity: 1,
        unitRaw: 'UN',
        unitPrice: 3.2,
      ),
      type: MatchType.willCreateNew,
      resolvedQuantity: 1,
      resolvedUnit: 'un',
      resolvedUnitPrice: 3.2,
      newProductName: 'Detergente Ype',
      newProductCategoryId: 'c-limpeza',
    );

    await usecase('compra-1', draftWith([scanned(arroz, 2, 28.9), newMatch]));

    verify(() => productRepo.create(any())).called(1);
    expect(added.single.unitPrice, 3.2);
  });

  test(
    'consolida varias linhas da nota do mesmo produto num item so',
    () async {
      when(() => purchaseRepo.getById('compra-1')).thenAnswer(
        (_) async => plannedPurchase([plannedItem('arroz', 1, 20.0)]),
      );

      await usecase(
        'compra-1',
        draftWith([
          scanned(arroz, 1, 20.0),
          scanned(arroz, 1, 20.0),
          scanned(arroz, 1, 20.0),
        ]),
      );

      expect(added, isEmpty);
      expect(updated.single.quantity, 3);
      expect(updated.single.unitPrice, 20.0);
    },
  );

  test(
    'usa preco medio ponderado quando as linhas tem precos diferentes',
    () async {
      when(() => purchaseRepo.getById('compra-1')).thenAnswer(
        (_) async => plannedPurchase([plannedItem('arroz', 1, 20.0)]),
      );

      await usecase(
        'compra-1',
        draftWith([scanned(arroz, 1, 10.0), scanned(arroz, 3, 20.0)]),
      );

      expect(updated.single.quantity, 4);
      expect(updated.single.unitPrice, closeTo(17.5, 0.001));
      expect(updated.single.totalPrice, closeTo(70.0, 0.001));
    },
  );

  test('consolida tambem itens novos que nao estavam planejados', () async {
    when(
      () => purchaseRepo.getById('compra-1'),
    ).thenAnswer((_) async => plannedPurchase([plannedItem('arroz', 1, 20.0)]));

    await usecase(
      'compra-1',
      draftWith([
        scanned(arroz, 1, 20.0),
        scanned(cafe, 1, 15.0),
        scanned(cafe, 2, 15.0),
      ]),
    );

    expect(added, hasLength(1));
    expect(added.single.productId, 'cafe');
    expect(added.single.quantity, 3);
  });

  test('remove linhas duplicadas do mesmo produto na compra', () async {
    when(() => purchaseRepo.getById('compra-1')).thenAnswer(
      (_) async => plannedPurchase([
        plannedItem('arroz', 1, 20.0),
        PurchaseItem(
          id: 'item-arroz-dup',
          purchaseId: 'compra-1',
          productId: 'arroz',
          quantity: 1,
          unitPrice: 20.0,
        ),
      ]),
    );

    await usecase('compra-1', draftWith([scanned(arroz, 2, 21.0)]));

    verify(() => itemRepo.removeItem('item-arroz-dup')).called(1);
    expect(updated.single.quantity, 2);
  });

  test('throws when the purchase does not exist', () async {
    when(() => purchaseRepo.getById('sumiu')).thenAnswer((_) async => null);

    expect(
      () => usecase('sumiu', draftWith([scanned(arroz, 1, 1)])),
      throwsA(isA<NfceImportException>()),
    );
  });

  test('wraps unexpected errors in NfceImportException', () async {
    when(() => purchaseRepo.getById('compra-1')).thenThrow(Exception('boom'));

    expect(
      () => usecase('compra-1', draftWith([scanned(arroz, 1, 1)])),
      throwsA(isA<NfceImportException>()),
    );
  });
}
