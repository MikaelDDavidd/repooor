import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/repositories/product_repository.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/get_total_spent_by_category.dart';

class _MockPurchaseRepository extends Mock implements PurchaseRepository {}

class _MockProductRepository extends Mock implements ProductRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  late _MockPurchaseRepository purchaseRepo;
  late _MockProductRepository productRepo;
  late GetTotalSpentByCategory usecase;

  setUp(() {
    purchaseRepo = _MockPurchaseRepository();
    productRepo = _MockProductRepository();
    usecase = GetTotalSpentByCategory(purchaseRepo, productRepo);
  });

  test('returns empty map when no priced items exist', () async {
    when(productRepo.getAll).thenAnswer(
      (_) async => const [
        Product(id: 'milk', name: 'Milk', categoryId: 'dairy', unit: 'L'),
      ],
    );
    when(() => purchaseRepo.getAllItemsByDateRange(any(), any())).thenAnswer(
      (_) async => const [
        PurchaseItem(id: 'a', purchaseId: 'p1', productId: 'milk', quantity: 1),
      ],
    );

    final result = await usecase(DateTime(2026, 5), DateTime(2026, 6));

    expect(result, isEmpty);
  });

  test('aggregates totals per category id', () async {
    when(productRepo.getAll).thenAnswer(
      (_) async => const [
        Product(id: 'milk', name: 'Milk', categoryId: 'dairy', unit: 'L'),
        Product(id: 'cheese', name: 'Cheese', categoryId: 'dairy', unit: 'kg'),
        Product(id: 'rice', name: 'Rice', categoryId: 'grains', unit: 'kg'),
      ],
    );
    when(() => purchaseRepo.getAllItemsByDateRange(any(), any())).thenAnswer(
      (_) async => const [
        PurchaseItem(
          id: 'a',
          purchaseId: 'p1',
          productId: 'milk',
          quantity: 2,
          unitPrice: 5,
        ),
        PurchaseItem(
          id: 'b',
          purchaseId: 'p1',
          productId: 'cheese',
          quantity: 1,
          unitPrice: 20,
        ),
        PurchaseItem(
          id: 'c',
          purchaseId: 'p1',
          productId: 'rice',
          quantity: 3,
          unitPrice: 4,
        ),
      ],
    );

    final result = await usecase(DateTime(2026, 5), DateTime(2026, 6));

    expect(result['dairy'], 30);
    expect(result['grains'], 12);
  });

  test('ignores items whose product is unknown', () async {
    when(productRepo.getAll).thenAnswer((_) async => const []);
    when(() => purchaseRepo.getAllItemsByDateRange(any(), any())).thenAnswer(
      (_) async => const [
        PurchaseItem(
          id: 'a',
          purchaseId: 'p1',
          productId: 'orphan',
          quantity: 1,
          unitPrice: 9,
        ),
      ],
    );

    final result = await usecase(DateTime(2026, 5), DateTime(2026, 6));

    expect(result, isEmpty);
  });
}
