import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/domain/entities/category.dart';

void main() {
  group('Category', () {
    const category = Category(
      id: 'cat-1',
      name: 'Frutas',
      icon: 0xe318,
      color: 0xFF4CAF50,
    );

    group('copyWith', () {
      test('should return identical entity when no parameters are passed', () {
        // Arrange
        // (category already defined above)

        // Act
        final result = category.copyWith();

        // Assert
        expect(result.id, category.id);
        expect(result.name, category.name);
        expect(result.icon, category.icon);
        expect(result.color, category.color);
      });

      test('should return entity with updated name when name is passed', () {
        // Arrange
        const newName = 'Verduras';

        // Act
        final result = category.copyWith(name: newName);

        // Assert
        expect(result.name, newName);
        expect(result.id, category.id);
        expect(result.icon, category.icon);
        expect(result.color, category.color);
      });

      test('should return entity with updated id when id is passed', () {
        // Arrange
        const newId = 'cat-99';

        // Act
        final result = category.copyWith(id: newId);

        // Assert
        expect(result.id, newId);
        expect(result.name, category.name);
      });

      test('should return entity with updated icon when icon is passed', () {
        // Arrange
        const newIcon = 0xe1234;

        // Act
        final result = category.copyWith(icon: newIcon);

        // Assert
        expect(result.icon, newIcon);
        expect(result.name, category.name);
      });

      test('should return entity with updated color when color is passed', () {
        // Arrange
        const newColor = 0xFFFF0000;

        // Act
        final result = category.copyWith(color: newColor);

        // Assert
        expect(result.color, newColor);
        expect(result.name, category.name);
      });

      test('should return entity with all fields updated when all parameters are passed', () {
        // Arrange
        const newId = 'cat-2';
        const newName = 'Laticinios';
        const newIcon = 0xe555;
        const newColor = 0xFF2196F3;

        // Act
        final result = category.copyWith(
          id: newId,
          name: newName,
          icon: newIcon,
          color: newColor,
        );

        // Assert
        expect(result.id, newId);
        expect(result.name, newName);
        expect(result.icon, newIcon);
        expect(result.color, newColor);
      });
    });
  });
}
