import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/category.dart';
import 'package:repooor/domain/repositories/category_repository.dart';
import 'package:repooor/domain/usecases/nfce/suggest_category_for_name.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late _MockCategoryRepository repo;
  late SuggestCategoryForName usecase;

  const categories = [
    Category(id: 'c-frutas', name: 'Frutas', icon: 0, color: 0),
    Category(id: 'c-carnes', name: 'Carnes', icon: 0, color: 0),
    Category(id: 'c-graos', name: 'Grãos', icon: 0, color: 0),
    Category(id: 'c-laticinios', name: 'Laticínios', icon: 0, color: 0),
    Category(id: 'c-bebidas', name: 'Bebidas', icon: 0, color: 0),
    Category(id: 'c-outros', name: 'Outros', icon: 0, color: 0),
  ];

  setUp(() {
    repo = _MockCategoryRepository();
    when(repo.getAll).thenAnswer((_) async => categories);
    usecase = SuggestCategoryForName(repo);
  });

  test('matches Frutas for "banana prata"', () async {
    expect(await usecase('banana prata'), 'c-frutas');
  });

  test('matches Carnes for "FRANGO INTEIRO"', () async {
    expect(await usecase('FRANGO INTEIRO'), 'c-carnes');
  });

  test('matches Grãos for "arroz tipo 1 5kg"', () async {
    expect(await usecase('arroz tipo 1 5kg'), 'c-graos');
  });

  test('matches Laticínios for "queijo mussarela"', () async {
    expect(await usecase('queijo mussarela'), 'c-laticinios');
  });

  test('matches Bebidas for "Café Pilão"', () async {
    expect(await usecase('Café Pilão'), 'c-bebidas');
  });

  test('falls back to "Outros" when no keyword matches', () async {
    expect(await usecase('xpto produto desconhecido zzz'), 'c-outros');
  });
}
