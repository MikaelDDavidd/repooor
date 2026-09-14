import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/data/repositories/product_match_repository_impl.dart';
import 'package:repooor/domain/entities/category.dart';
import 'package:repooor/domain/entities/nfce/match_type.dart';
import 'package:repooor/domain/entities/nfce/nfce_raw_item.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/repositories/category_repository.dart';
import 'package:repooor/domain/repositories/product_repository.dart';
import 'package:repooor/domain/usecases/nfce/suggest_category_for_name.dart';

class _MockProductRepository extends Mock implements ProductRepository {}

class _MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late _MockProductRepository productRepo;
  late _MockCategoryRepository categoryRepo;
  late ProductMatchRepositoryImpl repo;

  const products = [
    Product(id: 'p1', name: 'Arroz Tipo 1 5kg', categoryId: 'c1', unit: 'un'),
    Product(id: 'p2', name: 'Feijão Carioca 1kg', categoryId: 'c1', unit: 'un'),
    Product(id: 'p3', name: 'Leite Integral', categoryId: 'c2', unit: 'L'),
  ];

  const categories = [
    Category(id: 'c1', name: 'Grãos', icon: 0, color: 0),
    Category(id: 'c2', name: 'Laticínios', icon: 0, color: 0),
    Category(id: 'c-outros', name: 'Outros', icon: 0, color: 0),
  ];

  setUp(() {
    productRepo = _MockProductRepository();
    categoryRepo = _MockCategoryRepository();
    when(productRepo.getAll).thenAnswer((_) async => products);
    when(categoryRepo.getAll).thenAnswer((_) async => categories);
    repo = ProductMatchRepositoryImpl(
      productRepo,
      SuggestCategoryForName(categoryRepo),
    );
  });

  test('returns exact match when normalized names are identical', () async {
    final match = await repo.findMatch(
      const NfceRawItem(
        rawName: 'ARROZ TIPO 1 5KG',
        quantity: 2,
        unitRaw: 'UN',
        unitPrice: 28.9,
      ),
    );
    expect(match.type, MatchType.exact);
    expect(match.matchedProduct?.id, 'p1');
    expect(match.resolvedUnitPrice, 28.9);
  });

  test('returns fuzzyHigh for very similar name', () async {
    final match = await repo.findMatch(
      const NfceRawItem(
        rawName: 'arroz tipo 1 5kg pacote',
        quantity: 1,
        unitRaw: 'UN',
      ),
    );
    expect(match.type, anyOf(MatchType.fuzzyHigh, MatchType.exact));
    expect(match.matchedProduct?.id, 'p1');
  });

  test('returns willCreateNew when no product is close enough', () async {
    final match = await repo.findMatch(
      const NfceRawItem(
        rawName: 'XPTO BISCOITO RECHEADO BAUNILHA',
        quantity: 1,
        unitRaw: 'UN',
      ),
    );
    expect(match.type, MatchType.willCreateNew);
    expect(match.matchedProduct, isNull);
    expect(match.newProductName, isNotNull);
    expect(match.newProductCategoryId, 'c-outros');
  });

  test('maps SEFAZ unit "KG" to AppUnit.kg label', () async {
    final match = await repo.findMatch(
      const NfceRawItem(
        rawName: 'Queijo Mussarela Fatiado',
        quantity: 0.35,
        unitRaw: 'KG',
      ),
    );
    expect(match.resolvedUnit, 'kg');
  });

  test('searchSuggestions returns top matches by query', () async {
    final results = await repo.searchSuggestions('arroz', limit: 2);
    expect(results, isNotEmpty);
    expect(results.first.id, 'p1');
  });
}
