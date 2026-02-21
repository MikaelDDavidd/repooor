import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/get_consumption_by_product.dart';

class MockPurchaseRepository extends Mock implements PurchaseRepository {}

void main() {
  late MockPurchaseRepository mockRepository;
  late GetConsumptionByProduct usecase;

  final startDate = DateTime(2026, 1, 1);
  final endDate = DateTime(2026, 6, 30);

  setUp(() {
    mockRepository = MockPurchaseRepository();
    usecase = GetConsumptionByProduct(mockRepository);
  });

  group('GetConsumptionByProduct', () {
    test('should return empty list when product has no purchases', () async {
      // Arrange
      when(() => mockRepository.getByDateRange(startDate, endDate))
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase.call('prod-1', startDate, endDate);

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getByDateRange(startDate, endDate)).called(1);
    });

    test('should filter correctly by productId', () async {
      // Arrange
      final purchases = [
        Purchase(
          id: 'p-1',
          date: DateTime(2026, 1, 10),
          type: PurchaseType.main,
          items: const [
            PurchaseItem(id: 'pi-1', purchaseId: 'p-1', productId: 'prod-1', quantity: 3.0),
            PurchaseItem(id: 'pi-2', purchaseId: 'p-1', productId: 'prod-2', quantity: 5.0),
          ],
        ),
        Purchase(
          id: 'p-2',
          date: DateTime(2026, 2, 15),
          type: PurchaseType.midMonth,
          items: const [
            PurchaseItem(id: 'pi-3', purchaseId: 'p-2', productId: 'prod-1', quantity: 2.0),
            PurchaseItem(id: 'pi-4', purchaseId: 'p-2', productId: 'prod-3', quantity: 7.0),
          ],
        ),
      ];
      when(() => mockRepository.getByDateRange(startDate, endDate))
          .thenAnswer((_) async => purchases);

      // Act
      final result = await usecase.call('prod-1', startDate, endDate);

      // Assert
      expect(result.length, 2);
      expect(result[0].quantity, 3.0);
      expect(result[1].quantity, 2.0);
    });

    test('should return points sorted by date', () async {
      // Arrange
      final purchases = [
        Purchase(
          id: 'p-2',
          date: DateTime(2026, 3, 20),
          type: PurchaseType.main,
          items: const [
            PurchaseItem(id: 'pi-2', purchaseId: 'p-2', productId: 'prod-1', quantity: 4.0),
          ],
        ),
        Purchase(
          id: 'p-1',
          date: DateTime(2026, 1, 5),
          type: PurchaseType.main,
          items: const [
            PurchaseItem(id: 'pi-1', purchaseId: 'p-1', productId: 'prod-1', quantity: 2.0),
          ],
        ),
        Purchase(
          id: 'p-3',
          date: DateTime(2026, 2, 10),
          type: PurchaseType.midMonth,
          items: const [
            PurchaseItem(id: 'pi-3', purchaseId: 'p-3', productId: 'prod-1', quantity: 6.0),
          ],
        ),
      ];
      when(() => mockRepository.getByDateRange(startDate, endDate))
          .thenAnswer((_) async => purchases);

      // Act
      final result = await usecase.call('prod-1', startDate, endDate);

      // Assert
      expect(result.length, 3);
      expect(result[0].date, DateTime(2026, 1, 5));
      expect(result[0].quantity, 2.0);
      expect(result[1].date, DateTime(2026, 2, 10));
      expect(result[1].quantity, 6.0);
      expect(result[2].date, DateTime(2026, 3, 20));
      expect(result[2].quantity, 4.0);
    });

    test('should have correct fields on ProductConsumptionPoint', () async {
      // Arrange
      final purchaseDate = DateTime(2026, 5, 15);
      final purchases = [
        Purchase(
          id: 'p-1',
          date: purchaseDate,
          type: PurchaseType.main,
          items: const [
            PurchaseItem(id: 'pi-1', purchaseId: 'p-1', productId: 'prod-1', quantity: 8.5),
          ],
        ),
      ];
      when(() => mockRepository.getByDateRange(startDate, endDate))
          .thenAnswer((_) async => purchases);

      // Act
      final result = await usecase.call('prod-1', startDate, endDate);

      // Assert
      expect(result.length, 1);
      final point = result.first;
      expect(point.date, purchaseDate);
      expect(point.quantity, 8.5);
    });

    test('should return empty list when product exists but not in any purchase', () async {
      // Arrange
      final purchases = [
        Purchase(
          id: 'p-1',
          date: DateTime(2026, 1, 10),
          type: PurchaseType.main,
          items: const [
            PurchaseItem(id: 'pi-1', purchaseId: 'p-1', productId: 'prod-2', quantity: 3.0),
            PurchaseItem(id: 'pi-2', purchaseId: 'p-1', productId: 'prod-3', quantity: 5.0),
          ],
        ),
      ];
      when(() => mockRepository.getByDateRange(startDate, endDate))
          .thenAnswer((_) async => purchases);

      // Act
      final result = await usecase.call('prod-1', startDate, endDate);

      // Assert
      expect(result, isEmpty);
    });
  });
}
