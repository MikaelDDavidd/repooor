import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/get_consumption_by_category.dart';

class MockPurchaseRepository extends Mock implements PurchaseRepository {}

void main() {
  late MockPurchaseRepository mockRepository;
  late GetConsumptionByCategory usecase;

  final startDate = DateTime(2026, 1, 1);
  final endDate = DateTime(2026, 1, 31);

  setUp(() {
    mockRepository = MockPurchaseRepository();
    usecase = GetConsumptionByCategory(mockRepository);
  });

  group('GetConsumptionByCategory', () {
    test('should return empty map when there are no items', () async {
      // Arrange
      when(() => mockRepository.getAllItemsByDateRange(startDate, endDate))
          .thenAnswer((_) async => []);
      const products = <Product>[];

      // Act
      final result = await usecase.call(startDate, endDate, products);

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getAllItemsByDateRange(startDate, endDate))
          .called(1);
    });

    test('should group correctly by category', () async {
      // Arrange
      const items = [
        PurchaseItem(
          id: 'pi-1',
          purchaseId: 'p-1',
          productId: 'prod-1',
          quantity: 3.0,
        ),
        PurchaseItem(
          id: 'pi-2',
          purchaseId: 'p-1',
          productId: 'prod-2',
          quantity: 5.0,
        ),
      ];
      const products = [
        Product(id: 'prod-1', name: 'Arroz', categoryId: 'cat-grains', unit: 'kg'),
        Product(id: 'prod-2', name: 'Leite', categoryId: 'cat-dairy', unit: 'L'),
      ];
      when(() => mockRepository.getAllItemsByDateRange(startDate, endDate))
          .thenAnswer((_) async => items);

      // Act
      final result = await usecase.call(startDate, endDate, products);

      // Assert
      expect(result.length, 2);
      expect(result['cat-grains'], 3.0);
      expect(result['cat-dairy'], 5.0);
    });

    test('should sum quantities of same categoryId', () async {
      // Arrange
      const items = [
        PurchaseItem(
          id: 'pi-1',
          purchaseId: 'p-1',
          productId: 'prod-1',
          quantity: 2.0,
        ),
        PurchaseItem(
          id: 'pi-2',
          purchaseId: 'p-1',
          productId: 'prod-2',
          quantity: 4.0,
        ),
        PurchaseItem(
          id: 'pi-3',
          purchaseId: 'p-2',
          productId: 'prod-1',
          quantity: 1.5,
        ),
      ];
      const products = [
        Product(id: 'prod-1', name: 'Arroz', categoryId: 'cat-grains', unit: 'kg'),
        Product(id: 'prod-2', name: 'Feijao', categoryId: 'cat-grains', unit: 'kg'),
      ];
      when(() => mockRepository.getAllItemsByDateRange(startDate, endDate))
          .thenAnswer((_) async => items);

      // Act
      final result = await usecase.call(startDate, endDate, products);

      // Assert
      expect(result.length, 1);
      expect(result['cat-grains'], 7.5);
    });

    test('should skip items whose productId is not in products list', () async {
      // Arrange
      const items = [
        PurchaseItem(
          id: 'pi-1',
          purchaseId: 'p-1',
          productId: 'prod-1',
          quantity: 3.0,
        ),
        PurchaseItem(
          id: 'pi-2',
          purchaseId: 'p-1',
          productId: 'prod-unknown',
          quantity: 10.0,
        ),
      ];
      const products = [
        Product(id: 'prod-1', name: 'Arroz', categoryId: 'cat-grains', unit: 'kg'),
      ];
      when(() => mockRepository.getAllItemsByDateRange(startDate, endDate))
          .thenAnswer((_) async => items);

      // Act
      final result = await usecase.call(startDate, endDate, products);

      // Assert
      expect(result.length, 1);
      expect(result['cat-grains'], 3.0);
      expect(result.containsKey('prod-unknown'), isFalse);
    });
  });
}
