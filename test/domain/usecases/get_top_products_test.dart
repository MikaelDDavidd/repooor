import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/get_top_products.dart';

class MockPurchaseRepository extends Mock implements PurchaseRepository {}

void main() {
  late MockPurchaseRepository mockRepository;
  late GetTopProducts usecase;

  final startDate = DateTime(2026, 1, 1);
  final endDate = DateTime(2026, 1, 31);

  setUp(() {
    mockRepository = MockPurchaseRepository();
    usecase = GetTopProducts(mockRepository);
  });

  group('GetTopProducts', () {
    test('should return empty list when there are no items', () async {
      // Arrange
      when(() => mockRepository.getAllItemsByDateRange(startDate, endDate))
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase.call(startDate, endDate);

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getAllItemsByDateRange(startDate, endDate))
          .called(1);
    });

    test('should sort by totalQuantity descending', () async {
      // Arrange
      const items = [
        PurchaseItem(id: 'pi-1', purchaseId: 'p-1', productId: 'prod-a', quantity: 2.0),
        PurchaseItem(id: 'pi-2', purchaseId: 'p-1', productId: 'prod-b', quantity: 10.0),
        PurchaseItem(id: 'pi-3', purchaseId: 'p-1', productId: 'prod-c', quantity: 5.0),
      ];
      when(() => mockRepository.getAllItemsByDateRange(startDate, endDate))
          .thenAnswer((_) async => items);

      // Act
      final result = await usecase.call(startDate, endDate);

      // Assert
      expect(result.length, 3);
      expect(result[0].productId, 'prod-b');
      expect(result[0].totalQuantity, 10.0);
      expect(result[1].productId, 'prod-c');
      expect(result[1].totalQuantity, 5.0);
      expect(result[2].productId, 'prod-a');
      expect(result[2].totalQuantity, 2.0);
    });

    test('should respect limit parameter', () async {
      // Arrange
      const items = [
        PurchaseItem(id: 'pi-1', purchaseId: 'p-1', productId: 'prod-a', quantity: 1.0),
        PurchaseItem(id: 'pi-2', purchaseId: 'p-1', productId: 'prod-b', quantity: 2.0),
        PurchaseItem(id: 'pi-3', purchaseId: 'p-1', productId: 'prod-c', quantity: 3.0),
        PurchaseItem(id: 'pi-4', purchaseId: 'p-1', productId: 'prod-d', quantity: 4.0),
        PurchaseItem(id: 'pi-5', purchaseId: 'p-1', productId: 'prod-e', quantity: 5.0),
      ];
      when(() => mockRepository.getAllItemsByDateRange(startDate, endDate))
          .thenAnswer((_) async => items);

      // Act
      final result = await usecase.call(startDate, endDate, limit: 3);

      // Assert
      expect(result.length, 3);
      expect(result[0].productId, 'prod-e');
      expect(result[1].productId, 'prod-d');
      expect(result[2].productId, 'prod-c');
    });

    test('should have correct fields on TopProductResult', () async {
      // Arrange
      const items = [
        PurchaseItem(id: 'pi-1', purchaseId: 'p-1', productId: 'prod-x', quantity: 7.5),
      ];
      when(() => mockRepository.getAllItemsByDateRange(startDate, endDate))
          .thenAnswer((_) async => items);

      // Act
      final result = await usecase.call(startDate, endDate);

      // Assert
      expect(result.length, 1);
      final top = result.first;
      expect(top.productId, 'prod-x');
      expect(top.totalQuantity, 7.5);
    });

    test('should aggregate quantities of same product across multiple items', () async {
      // Arrange
      const items = [
        PurchaseItem(id: 'pi-1', purchaseId: 'p-1', productId: 'prod-a', quantity: 3.0),
        PurchaseItem(id: 'pi-2', purchaseId: 'p-2', productId: 'prod-a', quantity: 4.0),
        PurchaseItem(id: 'pi-3', purchaseId: 'p-1', productId: 'prod-b', quantity: 2.0),
      ];
      when(() => mockRepository.getAllItemsByDateRange(startDate, endDate))
          .thenAnswer((_) async => items);

      // Act
      final result = await usecase.call(startDate, endDate);

      // Assert
      expect(result.length, 2);
      expect(result[0].productId, 'prod-a');
      expect(result[0].totalQuantity, 7.0);
      expect(result[1].productId, 'prod-b');
      expect(result[1].totalQuantity, 2.0);
    });
  });
}
