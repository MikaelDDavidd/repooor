import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/core/di/nfce_providers.dart';
import 'package:repooor/domain/entities/nfce/imported_item_match.dart';
import 'package:repooor/domain/entities/nfce/match_type.dart';
import 'package:repooor/domain/entities/nfce/nfce_import_draft.dart';
import 'package:repooor/domain/entities/nfce/nfce_invoice.dart';
import 'package:repooor/domain/entities/nfce/nfce_qr_payload.dart';
import 'package:repooor/domain/entities/nfce/nfce_raw_item.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/usecases/nfce/fetch_nfce_invoice.dart';
import 'package:repooor/domain/usecases/nfce/import_nfce_as_purchase.dart';
import 'package:repooor/domain/usecases/nfce/match_products_for_import.dart';
import 'package:repooor/domain/usecases/projection/reconcile_purchase_with_nfce.dart';
import 'package:repooor/presentation/providers/nfce_providers.dart';

class _MockFetchNfceInvoice extends Mock implements FetchNfceInvoice {}

class _MockMatchProductsForImport extends Mock
    implements MatchProductsForImport {}

class _MockImportNfceAsPurchase extends Mock implements ImportNfceAsPurchase {}

class _MockReconcilePurchaseWithNfce extends Mock
    implements ReconcilePurchaseWithNfce {}

class _FakeNfceQrPayload extends Fake implements NfceQrPayload {}

class _FakeNfceInvoice extends Fake implements NfceInvoice {}

class _FakeNfceImportDraft extends Fake implements NfceImportDraft {}

const arroz = Product(id: 'arroz', name: 'Arroz', categoryId: 'c1', unit: 'kg');

const rawQr =
    'https://nfce.sefaz.pe.gov.br:444/nfce-web/consultarNFCe?p=26260741797488000107650010000587661002268142|2|1|1|ABC';

void main() {
  final invoice = NfceInvoice(
    chave: '26260741797488000107650010000587661002268142',
    issuedAt: DateTime(2026, 7, 24),
    emitenteNome: 'Mercado',
    emitenteCnpj: '',
    uf: 'PE',
    items: const [
      NfceRawItem(
        rawName: 'ARROZ',
        quantity: 2,
        unitRaw: 'KG',
        unitPrice: 31.5,
      ),
    ],
  );

  final matches = [
    ImportedItemMatch(
      source: invoice.items.first,
      type: MatchType.exact,
      matchedProduct: arroz,
      resolvedQuantity: 2,
      resolvedUnit: 'kg',
      resolvedUnitPrice: 31.5,
    ),
  ];

  late _MockFetchNfceInvoice fetch;
  late _MockMatchProductsForImport match;
  late _MockImportNfceAsPurchase import;
  late _MockReconcilePurchaseWithNfce reconcile;

  setUpAll(() {
    registerFallbackValue(_FakeNfceQrPayload());
    registerFallbackValue(_FakeNfceInvoice());
    registerFallbackValue(_FakeNfceImportDraft());
  });

  setUp(() {
    fetch = _MockFetchNfceInvoice();
    match = _MockMatchProductsForImport();
    import = _MockImportNfceAsPurchase();
    reconcile = _MockReconcilePurchaseWithNfce();
    when(() => fetch.call(any())).thenAnswer((_) async => invoice);
    when(() => match.call(any())).thenAnswer((_) async => matches);
    when(() => import.call(any())).thenAnswer((_) async => 'nova-compra');
    when(
      () => reconcile.call(any(), any()),
    ).thenAnswer((_) async => 'compra-1');
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        fetchNfceInvoiceProvider.overrideWithValue(fetch),
        matchProductsForImportProvider.overrideWithValue(match),
        importNfceAsPurchaseProvider.overrideWithValue(import),
        reconcilePurchaseWithNfceProvider.overrideWithValue(reconcile),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> scanAndConfirm(ProviderContainer container) async {
    final notifier = container.read(nfceImportProvider.notifier);
    await notifier.onQrDetected(rawQr);
    await notifier.confirmImport();
  }

  test('creates a new purchase when not reconciling', () async {
    final container = buildContainer();

    await scanAndConfirm(container);

    verify(() => import.call(any())).called(1);
    verifyNever(() => reconcile.call(any(), any()));
    final state = container.read(nfceImportProvider) as NfceDone;
    expect(state.purchaseId, 'nova-compra');
    expect(state.reconciled, isFalse);
  });

  test(
    'reconciles the target purchase instead of creating a new one',
    () async {
      final container = buildContainer();
      container
          .read(nfceImportProvider.notifier)
          .startReconciliation('compra-1');

      await scanAndConfirm(container);

      verify(() => reconcile.call('compra-1', any())).called(1);
      verifyNever(() => import.call(any()));
      final state = container.read(nfceImportProvider) as NfceDone;
      expect(state.purchaseId, 'compra-1');
      expect(state.reconciled, isTrue);
    },
  );

  test('exposes the reconciliation target while it is active', () {
    final container = buildContainer();
    final notifier = container.read(nfceImportProvider.notifier);

    expect(notifier.isReconciling, isFalse);
    notifier.startReconciliation('compra-1');
    expect(notifier.isReconciling, isTrue);
    expect(notifier.reconcileTargetId, 'compra-1');
  });

  test('reset clears the reconciliation target', () async {
    final container = buildContainer();
    final notifier = container.read(nfceImportProvider.notifier);
    notifier.startReconciliation('compra-1');

    notifier.reset();
    await scanAndConfirm(container);

    verify(() => import.call(any())).called(1);
    verifyNever(() => reconcile.call(any(), any()));
  });

  test(
    'keeps the scanned invoice available for review before confirming',
    () async {
      final container = buildContainer();
      container
          .read(nfceImportProvider.notifier)
          .startReconciliation('compra-1');

      await container.read(nfceImportProvider.notifier).onQrDetected(rawQr);

      final state = container.read(nfceImportProvider);
      expect(state, isA<NfceReviewing>());
      expect((state as NfceReviewing).draft.invoice.items, hasLength(1));
      verifyNever(() => reconcile.call(any(), any()));
    },
  );
}
