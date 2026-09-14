import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/projection/get_last_prices.dart';

class _MockPurchaseRepository extends Mock implements PurchaseRepository {}

PurchaseItem item(String productId, double qty, double? price) => PurchaseItem(
  id: 'i-$productId-$price',
  purchaseId: 'p',
  productId: productId,
  quantity: qty,
  unitPrice: price,
);

void main() {
  late _MockPurchaseRepository repo;
  late GetLastPrices usecase;

  setUp(() {
    repo = _MockPurchaseRepository();
    usecase = GetLastPrices(repo);
  });

  test('returns the most recent price for each product', () async {
    when(() => repo.getAll()).thenAnswer(
      (_) async => [
        Purchase(
          id: 'old',
          date: DateTime(2026, 1, 10),
          type: PurchaseType.main,
          items: [item('arroz', 1, 20.0)],
        ),
        Purchase(
          id: 'new',
          date: DateTime(2026, 6, 10),
          type: PurchaseType.main,
          items: [item('arroz', 1, 28.9)],
        ),
      ],
    );

    final result = await usecase();

    expect(result['arroz']!.unitPrice, 28.9);
    expect(result['arroz']!.date, DateTime(2026, 6, 10));
  });

  test('ignores items without price', () async {
    when(() => repo.getAll()).thenAnswer(
      (_) async => [
        Purchase(
          id: 'p1',
          date: DateTime(2026, 6, 10),
          type: PurchaseType.main,
          items: [item('feijao', 1, null)],
        ),
      ],
    );

    expect(await usecase(), isEmpty);
  });

  test(
    'ignores planned purchases so estimates do not feed themselves',
    () async {
      when(() => repo.getAll()).thenAnswer(
        (_) async => [
          Purchase(
            id: 'real',
            date: DateTime(2026, 3, 1),
            type: PurchaseType.main,
            items: [item('arroz', 1, 25.0)],
          ),
          Purchase(
            id: 'planned',
            date: DateTime(2026, 7, 1),
            type: PurchaseType.main,
            status: PurchaseStatus.planned,
            items: [item('arroz', 1, 99.0)],
          ),
        ],
      );

      final result = await usecase();

      expect(result['arroz']!.unitPrice, 25.0);
    },
  );

  test('keeps prices of different products separated', () async {
    when(() => repo.getAll()).thenAnswer(
      (_) async => [
        Purchase(
          id: 'p1',
          date: DateTime(2026, 6, 10),
          type: PurchaseType.main,
          items: [item('arroz', 1, 28.9), item('feijao', 2, 8.5)],
        ),
      ],
    );

    final result = await usecase();

    expect(result, hasLength(2));
    expect(result['feijao']!.unitPrice, 8.5);
  });

  test('returns empty map when there are no purchases', () async {
    when(() => repo.getAll()).thenAnswer((_) async => []);
    expect(await usecase(), isEmpty);
  });
}
