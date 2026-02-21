import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/models/category_model.dart';
import 'package:repooor/domain/entities/category.dart';

void main() {
  group('CategoryModel', () {
    const model = CategoryModel(
      id: 'cat-1',
      name: 'Frutas',
      icon: 0xe318,
      color: 0xFF4CAF50,
    );

    final map = {
      'id': 'cat-1',
      'name': 'Frutas',
      'icon': 0xe318,
      'color': 0xFF4CAF50,
    };

    const entity = Category(
      id: 'cat-1',
      name: 'Frutas',
      icon: 0xe318,
      color: 0xFF4CAF50,
    );

    group('toMap', () {
      test('should return a map with all fields correctly mapped', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toMap();

        // Assert
        expect(result['id'], 'cat-1');
        expect(result['name'], 'Frutas');
        expect(result['icon'], 0xe318);
        expect(result['color'], 0xFF4CAF50);
      });
    });

    group('fromMap', () {
      test('should return a valid model when map contains all required fields', () {
        // Arrange
        // (map already defined above)

        // Act
        final result = CategoryModel.fromMap(map);

        // Assert
        expect(result.id, 'cat-1');
        expect(result.name, 'Frutas');
        expect(result.icon, 0xe318);
        expect(result.color, 0xFF4CAF50);
      });
    });

    group('toEntity', () {
      test('should return a Category entity with matching fields', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toEntity();

        // Assert
        expect(result.id, model.id);
        expect(result.name, model.name);
        expect(result.icon, model.icon);
        expect(result.color, model.color);
      });
    });

    group('fromEntity', () {
      test('should return a CategoryModel with matching fields from entity', () {
        // Arrange
        // (entity already defined above)

        // Act
        final result = CategoryModel.fromEntity(entity);

        // Assert
        expect(result.id, entity.id);
        expect(result.name, entity.name);
        expect(result.icon, entity.icon);
        expect(result.color, entity.color);
      });
    });

    group('round-trip', () {
      test('should preserve all data through entity -> model -> map -> model -> entity', () {
        // Arrange
        const originalEntity = Category(
          id: 'cat-rt',
          name: 'Round Trip',
          icon: 0xe999,
          color: 0xFFABCDEF,
        );

        // Act
        final modelFromEntity = CategoryModel.fromEntity(originalEntity);
        final mapFromModel = modelFromEntity.toMap();
        final modelFromMap = CategoryModel.fromMap(mapFromModel);
        final finalEntity = modelFromMap.toEntity();

        // Assert
        expect(finalEntity.id, originalEntity.id);
        expect(finalEntity.name, originalEntity.name);
        expect(finalEntity.icon, originalEntity.icon);
        expect(finalEntity.color, originalEntity.color);
      });

      test('should preserve all data through map -> model -> entity -> model -> map', () {
        // Arrange
        final originalMap = <String, dynamic>{
          'id': 'cat-rt2',
          'name': 'Map Round Trip',
          'icon': 0xe777,
          'color': 0xFF123456,
        };

        // Act
        final modelFromMap = CategoryModel.fromMap(originalMap);
        final entityFromModel = modelFromMap.toEntity();
        final modelFromEntity = CategoryModel.fromEntity(entityFromModel);
        final finalMap = modelFromEntity.toMap();

        // Assert
        expect(finalMap['id'], originalMap['id']);
        expect(finalMap['name'], originalMap['name']);
        expect(finalMap['icon'], originalMap['icon']);
        expect(finalMap['color'], originalMap['color']);
      });
    });
  });
}
