import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/domain/entities/pantry_item.dart';

void main() {
  group('PantryItem', () {
    const item = PantryItem(
      id: 'pantry-1',
      productId: 'prod-1',
      currentQuantity: 3.0,
      idealQuantity: 10.0,
    );

    group('copyWith', () {
      test('should return identical entity when no parameters are passed', () {
        // Arrange
        // (item already defined above)

        // Act
        final result = item.copyWith();

        // Assert
        expect(result.id, item.id);
        expect(result.productId, item.productId);
        expect(result.currentQuantity, item.currentQuantity);
        expect(result.idealQuantity, item.idealQuantity);
      });

      test('should return entity with updated id when id is passed', () {
        // Arrange
        const newId = 'pantry-99';

        // Act
        final result = item.copyWith(id: newId);

        // Assert
        expect(result.id, newId);
        expect(result.productId, item.productId);
        expect(result.currentQuantity, item.currentQuantity);
        expect(result.idealQuantity, item.idealQuantity);
      });

      test('should return entity with updated productId when productId is passed', () {
        // Arrange
        const newProductId = 'prod-42';

        // Act
        final result = item.copyWith(productId: newProductId);

        // Assert
        expect(result.productId, newProductId);
        expect(result.id, item.id);
      });

      test('should return entity with updated currentQuantity when currentQuantity is passed', () {
        // Arrange
        const newQuantity = 7.5;

        // Act
        final result = item.copyWith(currentQuantity: newQuantity);

        // Assert
        expect(result.currentQuantity, newQuantity);
        expect(result.idealQuantity, item.idealQuantity);
      });

      test('should return entity with updated idealQuantity when idealQuantity is passed', () {
        // Arrange
        const newIdeal = 20.0;

        // Act
        final result = item.copyWith(idealQuantity: newIdeal);

        // Assert
        expect(result.idealQuantity, newIdeal);
        expect(result.currentQuantity, item.currentQuantity);
      });

      test('should return entity with all fields updated when all parameters are passed', () {
        // Arrange
        const newId = 'pantry-2';
        const newProductId = 'prod-2';
        const newCurrent = 5.0;
        const newIdeal = 15.0;

        // Act
        final result = item.copyWith(
          id: newId,
          productId: newProductId,
          currentQuantity: newCurrent,
          idealQuantity: newIdeal,
        );

        // Assert
        expect(result.id, newId);
        expect(result.productId, newProductId);
        expect(result.currentQuantity, newCurrent);
        expect(result.idealQuantity, newIdeal);
      });
    });

    group('stockRatio', () {
      test('should return correct ratio when idealQuantity is greater than zero', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 5.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.stockRatio;

        // Assert
        expect(result, 0.5);
      });

      test('should return 1.0 when idealQuantity is zero', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 5.0,
          idealQuantity: 0.0,
        );

        // Act
        final result = pantryItem.stockRatio;

        // Assert
        expect(result, 1.0);
      });

      test('should return ratio greater than 1 when currentQuantity exceeds idealQuantity', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 15.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.stockRatio;

        // Assert
        expect(result, 1.5);
      });

      test('should return 0 when currentQuantity is zero', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 0.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.stockRatio;

        // Assert
        expect(result, 0.0);
      });
    });

    group('isLowStock', () {
      test('should return true when stockRatio is less than 0.5', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 2.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.isLowStock;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when stockRatio is exactly 0.5', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 5.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.isLowStock;

        // Assert
        expect(result, isFalse);
      });

      test('should return false when stockRatio is above 0.5', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 8.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.isLowStock;

        // Assert
        expect(result, isFalse);
      });
    });

    group('isMediumStock', () {
      test('should return true when stockRatio is exactly 0.5', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 5.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.isMediumStock;

        // Assert
        expect(result, isTrue);
      });

      test('should return true when stockRatio is between 0.5 and 1.0', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 7.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.isMediumStock;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when stockRatio is less than 0.5', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 2.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.isMediumStock;

        // Assert
        expect(result, isFalse);
      });

      test('should return false when stockRatio is exactly 1.0', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 10.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.isMediumStock;

        // Assert
        expect(result, isFalse);
      });
    });

    group('isFullStock', () {
      test('should return true when stockRatio is exactly 1.0', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 10.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.isFullStock;

        // Assert
        expect(result, isTrue);
      });

      test('should return true when stockRatio is greater than 1.0', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 15.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.isFullStock;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when stockRatio is less than 1.0', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 8.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.isFullStock;

        // Assert
        expect(result, isFalse);
      });

      test('should return true when idealQuantity is zero', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 0.0,
          idealQuantity: 0.0,
        );

        // Act
        final result = pantryItem.isFullStock;

        // Assert
        expect(result, isTrue);
      });
    });

    group('deficit', () {
      test('should return difference when currentQuantity is less than idealQuantity', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 3.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.deficit;

        // Assert
        expect(result, 7.0);
      });

      test('should return 0 when currentQuantity equals idealQuantity', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 10.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.deficit;

        // Assert
        expect(result, 0.0);
      });

      test('should return 0 when currentQuantity exceeds idealQuantity', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 15.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.deficit;

        // Assert
        expect(result, 0.0);
      });

      test('should return idealQuantity when currentQuantity is zero', () {
        // Arrange
        const pantryItem = PantryItem(
          id: 'p-1',
          productId: 'prod-1',
          currentQuantity: 0.0,
          idealQuantity: 10.0,
        );

        // Act
        final result = pantryItem.deficit;

        // Assert
        expect(result, 10.0);
      });
    });
  });
}
