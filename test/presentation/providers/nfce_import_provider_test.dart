import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/core/di/nfce_providers.dart';
import 'package:repooor/domain/entities/nfce/imported_item_match.dart';
import 'package:repooor/domain/entities/nfce/match_type.dart';
import 'package:repooor/domain/entities/nfce/nfce_invoice.dart';
import 'package:repooor/domain/entities/nfce/nfce_qr_payload.dart';
import 'package:repooor/domain/entities/nfce/nfce_raw_item.dart';
import 'package:repooor/domain/usecases/nfce/fetch_nfce_invoice.dart';
import 'package:repooor/domain/usecases/nfce/match_products_for_import.dart';
import 'package:repooor/presentation/providers/nfce_providers.dart';

class _MockFetchNfceInvoice extends Mock implements FetchNfceInvoice {}

class _MockMatchProductsForImport extends Mock
    implements MatchProductsForImport {}

class _FakeNfceQrPayload extends Fake implements NfceQrPayload {}

class _FakeNfceInvoice extends Fake implements NfceInvoice {}

void main() {
  const rawQr =
      'https://nfce.sefaz.pe.gov.br:444/nfce-web/consultarNFCe?p=26260741797488000107650010000587661002268142|2|1|1|67A5B6F0';

  final invoice = NfceInvoice(
    chave: '26260741797488000107650010000587661002268142',
    issuedAt: DateTime(2026, 7, 2, 18, 50),
    emitenteNome: 'COMERCIAL BRASIL',
    emitenteCnpj: '41.797.488/0001-07',
    uf: 'PE',
    items: const [
      NfceRawItem(
        rawName: 'BISCOITO MARIA',
        quantity: 1,
        unitRaw: 'UN',
        unitPrice: 6.15,
      ),
    ],
  );

  final matches = [
    ImportedItemMatch(
      source: invoice.items.first,
      type: MatchType.willCreateNew,
      resolvedQuantity: 1,
      resolvedUnit: 'un',
      resolvedUnitPrice: 6.15,
      newProductName: 'Biscoito Maria',
    ),
  ];

  late _MockFetchNfceInvoice fetch;
  late _MockMatchProductsForImport match;

  setUpAll(() {
    registerFallbackValue(_FakeNfceQrPayload());
    registerFallbackValue(_FakeNfceInvoice());
  });

  setUp(() {
    fetch = _MockFetchNfceInvoice();
    match = _MockMatchProductsForImport();
    when(() => fetch.call(any())).thenAnswer((_) async => invoice);
    when(() => match.call(any())).thenAnswer((_) async => matches);
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        fetchNfceInvoiceProvider.overrideWithValue(fetch),
        matchProductsForImportProvider.overrideWithValue(match),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('keeps the reviewing state when no widget is listening', () async {
    final container = buildContainer();

    await container.read(nfceImportProvider.notifier).onQrDetected(rawQr);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(nfceImportProvider), isA<NfceReviewing>());
  });

  test('exposes the parsed invoice to a later listener', () async {
    final container = buildContainer();

    await container.read(nfceImportProvider.notifier).onQrDetected(rawQr);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(nfceImportProvider);
    expect(state, isA<NfceReviewing>());
    expect((state as NfceReviewing).draft.invoice.items, hasLength(1));
  });

  test('reset returns to idle', () async {
    final container = buildContainer();

    await container.read(nfceImportProvider.notifier).onQrDetected(rawQr);
    container.read(nfceImportProvider.notifier).reset();

    expect(container.read(nfceImportProvider), isA<NfceIdle>());
  });
}
