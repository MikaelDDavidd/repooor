import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/domain/entities/product.dart';

void main() {
  group('Product', () {
    const product = Product(
      id: 'prod-1',
      name: 'Banana',
      categoryId: 'cat-1',
      unit: 'kg',
    );

    group('copyWith', () {
      test('should return identical entity when no parameters are passed', () {
        // Arrange
        // (product already defined above)

        // Act
        final result = product.copyWith();

        // Assert
        expect(result.id, product.id);
        expect(result.name, product.name);
        expect(result.categoryId, product.categoryId);
        expect(result.unit, product.unit);
      });

      test('should return entity with updated name when name is passed', () {
        // Arrange
        const newName = 'Maca';

        // Act
        final result = product.copyWith(name: newName);

        // Assert
        expect(result.name, newName);
        expect(result.id, product.id);
        expect(result.categoryId, product.categoryId);
        expect(result.unit, product.unit);
      });

      test('should return entity with updated id when id is passed', () {
        // Arrange
        const newId = 'prod-99';

        // Act
        final result = product.copyWith(id: newId);

        // Assert
        expect(result.id, newId);
        expect(result.name, product.name);
      });

      test('should return entity with updated categoryId when categoryId is passed', () {
        // Arrange
        const newCategoryId = 'cat-5';

        // Act
        final result = product.copyWith(categoryId: newCategoryId);

        // Assert
        expect(result.categoryId, newCategoryId);
        expect(result.name, product.name);
      });

      test('should return entity with updated unit when unit is passed', () {
        // Arrange
        const newUnit = 'un';

        // Act
        final result = product.copyWith(unit: newUnit);

        // Assert
        expect(result.unit, newUnit);
        expect(result.name, product.name);
      });

      test('should return entity with all fields updated when all parameters are passed', () {
        // Arrange
        const newId = 'prod-2';
        const newName = 'Leite';
        const newCategoryId = 'cat-3';
        const newUnit = 'L';

        // Act
        final result = product.copyWith(
          id: newId,
          name: newName,
          categoryId: newCategoryId,
          unit: newUnit,
        );

        // Assert
        expect(result.id, newId);
        expect(result.name, newName);
        expect(result.categoryId, newCategoryId);
        expect(result.unit, newUnit);
      });
    });
  });
}
