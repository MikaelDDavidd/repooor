import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/get_total_spent_by_month.dart';

class _MockPurchaseRepository extends Mock implements PurchaseRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  late _MockPurchaseRepository repo;
  late GetTotalSpentByMonth usecase;

  setUp(() {
    repo = _MockPurchaseRepository();
    usecase = GetTotalSpentByMonth(repo);
  });

  test('returns zero when no purchases in range', () async {
    when(() => repo.getByDateRange(any(), any())).thenAnswer((_) async => []);

    final result = await usecase(2026, 5);

    expect(result, 0);
  });

  test(
    'sums totalPrice of all purchases ignoring items without unit price',
    () async {
      final purchases = [
        Purchase(
          id: 'p1',
          date: DateTime(2026, 5, 10),
          type: PurchaseType.main,
          items: const [
            PurchaseItem(
              id: 'a',
              purchaseId: 'p1',
              productId: 'x',
              quantity: 2,
              unitPrice: 5,
            ),
            PurchaseItem(
              id: 'b',
              purchaseId: 'p1',
              productId: 'y',
              quantity: 1,
              unitPrice: 3,
            ),
          ],
        ),
        Purchase(
          id: 'p2',
          date: DateTime(2026, 5, 20),
          type: PurchaseType.midMonth,
          items: const [
            PurchaseItem(
              id: 'c',
              purchaseId: 'p2',
              productId: 'z',
              quantity: 4,
            ),
            PurchaseItem(
              id: 'd',
              purchaseId: 'p2',
              productId: 'w',
              quantity: 2,
              unitPrice: 7,
            ),
          ],
        ),
      ];
      when(
        () => repo.getByDateRange(any(), any()),
      ).thenAnswer((_) async => purchases);

      final result = await usecase(2026, 5);

      expect(result, 27);
    },
  );

  test('passes correct start and end dates to repository', () async {
    when(() => repo.getByDateRange(any(), any())).thenAnswer((_) async => []);

    await usecase(2026, 5);

    verify(
      () => repo.getByDateRange(DateTime(2026, 5), DateTime(2026, 6)),
    ).called(1);
  });
}
