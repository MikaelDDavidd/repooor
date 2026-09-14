import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/get_price_history_by_product.dart';

class _MockPurchaseRepository extends Mock implements PurchaseRepository {}

void main() {
  late _MockPurchaseRepository repo;
  late GetPriceHistoryByProduct usecase;

  setUp(() {
    repo = _MockPurchaseRepository();
    usecase = GetPriceHistoryByProduct(repo);
  });

  test('returns empty list when product has no priced items', () async {
    when(repo.getAll).thenAnswer(
      (_) async => [
        Purchase(
          id: 'p1',
          date: DateTime(2026, 1, 1),
          type: PurchaseType.main,
          items: const [
            PurchaseItem(
              id: 'a',
              purchaseId: 'p1',
              productId: 'milk',
              quantity: 1,
            ),
          ],
        ),
      ],
    );

    final result = await usecase('milk');

    expect(result, isEmpty);
  });

  test('returns price points sorted by date ascending', () async {
    when(repo.getAll).thenAnswer(
      (_) async => [
        Purchase(
          id: 'p2',
          date: DateTime(2026, 3, 5),
          type: PurchaseType.main,
          items: const [
            PurchaseItem(
              id: 'b',
              purchaseId: 'p2',
              productId: 'milk',
              quantity: 2,
              unitPrice: 5,
            ),
          ],
        ),
        Purchase(
          id: 'p1',
          date: DateTime(2026, 1, 10),
          type: PurchaseType.main,
          items: const [
            PurchaseItem(
              id: 'a',
              purchaseId: 'p1',
              productId: 'milk',
              quantity: 1,
              unitPrice: 4,
            ),
          ],
        ),
      ],
    );

    final result = await usecase('milk');

    expect(result, hasLength(2));
    expect(result.first.unitPrice, 4);
    expect(result.first.date, DateTime(2026, 1, 10));
    expect(result.last.unitPrice, 5);
  });

  test('filters items belonging to the requested product only', () async {
    when(repo.getAll).thenAnswer(
      (_) async => [
        Purchase(
          id: 'p1',
          date: DateTime(2026, 2, 1),
          type: PurchaseType.main,
          items: const [
            PurchaseItem(
              id: 'a',
              purchaseId: 'p1',
              productId: 'milk',
              quantity: 1,
              unitPrice: 4,
            ),
            PurchaseItem(
              id: 'b',
              purchaseId: 'p1',
              productId: 'rice',
              quantity: 1,
              unitPrice: 10,
            ),
          ],
        ),
      ],
    );

    final result = await usecase('milk');

    expect(result, hasLength(1));
    expect(result.single.unitPrice, 4);
  });
}
