import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/nfce/imported_item_match.dart';
import 'package:repooor/domain/entities/nfce/match_type.dart';
import 'package:repooor/domain/entities/nfce/nfce_invoice.dart';
import 'package:repooor/domain/entities/nfce/nfce_raw_item.dart';
import 'package:repooor/domain/repositories/product_match_repository.dart';
import 'package:repooor/domain/usecases/nfce/match_products_for_import.dart';

class _MockProductMatchRepository extends Mock
    implements ProductMatchRepository {}

class _FakeRawItem extends Fake implements NfceRawItem {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRawItem());
  });

  late _MockProductMatchRepository repo;
  late MatchProductsForImport usecase;

  setUp(() {
    repo = _MockProductMatchRepository();
    usecase = MatchProductsForImport(repo);
  });

  ImportedItemMatch matchOf(NfceRawItem item, MatchType type) {
    return ImportedItemMatch(
      source: item,
      type: type,
      resolvedQuantity: item.quantity,
      resolvedUnit: item.unitRaw,
    );
  }

  test('calls findMatch for each invoice item and preserves order', () async {
    final items = const [
      NfceRawItem(rawName: 'A', quantity: 1, unitRaw: 'UN'),
      NfceRawItem(rawName: 'B', quantity: 2, unitRaw: 'KG'),
      NfceRawItem(rawName: 'C', quantity: 3, unitRaw: 'UN'),
    ];
    when(() => repo.findMatch(any())).thenAnswer((invocation) async {
      final item = invocation.positionalArguments.first as NfceRawItem;
      return matchOf(item, MatchType.exact);
    });

    final result = await usecase(
      NfceInvoice(
        chave: 'k',
        issuedAt: DateTime(2026),
        emitenteNome: 'X',
        emitenteCnpj: '',
        uf: 'PE',
        items: items,
      ),
    );

    expect(result, hasLength(3));
    expect(result.map((m) => m.source.rawName).toList(), ['A', 'B', 'C']);
    verify(() => repo.findMatch(any())).called(3);
  });

  test('returns empty list when invoice has no items', () async {
    final result = await usecase(
      NfceInvoice(
        chave: 'k',
        issuedAt: DateTime(2026),
        emitenteNome: 'X',
        emitenteCnpj: '',
        uf: 'PE',
        items: const [],
      ),
    );
    expect(result, isEmpty);
    verifyNever(() => repo.findMatch(any()));
  });
}
