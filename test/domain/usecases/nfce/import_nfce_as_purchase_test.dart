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
import 'package:repooor/domain/usecases/nfce/import_nfce_as_purchase.dart';

class _MockProductRepository extends Mock implements ProductRepository {}

class _MockPurchaseRepository extends Mock implements PurchaseRepository {}

class _MockPurchaseItemRepository extends Mock
    implements PurchaseItemRepository {}

class _FakeProduct extends Fake implements Product {}

class _FakePurchase extends Fake implements Purchase {}

class _FakePurchaseItem extends Fake implements PurchaseItem {}

NfceInvoice _invoice() => NfceInvoice(
  chave: '26',
  issuedAt: DateTime(2026, 5, 15),
  emitenteNome: 'X',
  emitenteCnpj: '',
  uf: 'PE',
  items: const [],
);

NfceImportDraft _draftWith(List<ImportedItemMatch> matches) =>
    NfceImportDraft(invoice: _invoice(), matches: matches);

ImportedItemMatch _exactMatch({required String productId}) => ImportedItemMatch(
  source: const NfceRawItem(
    rawName: 'X',
    quantity: 2,
    unitRaw: 'UN',
    unitPrice: 5,
  ),
  type: MatchType.exact,
  matchedProduct: Product(
    id: productId,
    name: 'X',
    categoryId: 'c',
    unit: 'un',
  ),
  resolvedQuantity: 2,
  resolvedUnit: 'un',
  resolvedUnitPrice: 5,
);

ImportedItemMatch _newProductMatch({String? name}) => ImportedItemMatch(
  source: const NfceRawItem(
    rawName: 'Y',
    quantity: 1,
    unitRaw: 'KG',
    unitPrice: 9,
  ),
  type: MatchType.willCreateNew,
  resolvedQuantity: 1,
  resolvedUnit: 'kg',
  resolvedUnitPrice: 9,
  newProductName: name ?? 'Novo Produto',
  newProductCategoryId: 'c-outros',
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeProduct());
    registerFallbackValue(_FakePurchase());
    registerFallbackValue(_FakePurchaseItem());
  });

  late _MockProductRepository productRepo;
  late _MockPurchaseRepository purchaseRepo;
  late _MockPurchaseItemRepository itemRepo;
  late ImportNfceAsPurchase usecase;

  setUp(() {
    productRepo = _MockProductRepository();
    purchaseRepo = _MockPurchaseRepository();
    itemRepo = _MockPurchaseItemRepository();
    when(() => productRepo.create(any())).thenAnswer((_) async {});
    when(() => purchaseRepo.create(any())).thenAnswer((_) async {});
    when(() => itemRepo.addItem(any())).thenAnswer((_) async {});
    usecase = ImportNfceAsPurchase(
      EnsureMatchedProducts(productRepo),
      purchaseRepo,
      itemRepo,
    );
  });

  test('does not create products when all matches are exact', () async {
    final draft = _draftWith([
      _exactMatch(productId: 'p1'),
      _exactMatch(productId: 'p2'),
    ]);
    await usecase(draft);
    verifyNever(() => productRepo.create(any()));
    verify(() => purchaseRepo.create(any())).called(1);
    verify(() => itemRepo.addItem(any())).called(2);
  });

  test('creates products for willCreateNew matches and links them', () async {
    final draft = _draftWith([
      _exactMatch(productId: 'p1'),
      _newProductMatch(name: 'Maracujá'),
    ]);
    await usecase(draft);
    verify(() => productRepo.create(any())).called(1);
    verify(() => itemRepo.addItem(any())).called(2);
  });

  test('persists purchase items with unitPrice from match', () async {
    final captured = <PurchaseItem>[];
    when(() => itemRepo.addItem(any())).thenAnswer((invocation) async {
      captured.add(invocation.positionalArguments.first as PurchaseItem);
    });
    final draft = _draftWith([_exactMatch(productId: 'p1')]);
    await usecase(draft);
    expect(captured.single.unitPrice, 5);
    expect(captured.single.quantity, 2);
    expect(captured.single.productId, 'p1');
  });

  test('returns purchase id as String UUID', () async {
    final draft = _draftWith([_exactMatch(productId: 'p1')]);
    final id = await usecase(draft);
    expect(id, isNotEmpty);
  });

  test('wraps unexpected error in NfceImportException', () async {
    when(() => purchaseRepo.create(any())).thenThrow(Exception('boom'));
    final draft = _draftWith([_exactMatch(productId: 'p1')]);
    expect(() => usecase(draft), throwsA(isA<NfceImportException>()));
  });
}
