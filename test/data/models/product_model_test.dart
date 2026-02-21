import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/models/product_model.dart';
import 'package:repooor/domain/entities/product.dart';

void main() {
  group('ProductModel', () {
    const model = ProductModel(
      id: 'prod-1',
      name: 'Banana',
      categoryId: 'cat-1',
      unit: 'kg',
    );

    final map = {
      'id': 'prod-1',
      'name': 'Banana',
      'category_id': 'cat-1',
      'unit': 'kg',
    };

    const entity = Product(
      id: 'prod-1',
      name: 'Banana',
      categoryId: 'cat-1',
      unit: 'kg',
    );

    group('toMap', () {
      test('should return a map with all fields correctly mapped', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toMap();

        // Assert
        expect(result['id'], 'prod-1');
        expect(result['name'], 'Banana');
        expect(result['category_id'], 'cat-1');
        expect(result['unit'], 'kg');
      });

      test('should use snake_case key for categoryId', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toMap();

        // Assert
        expect(result.containsKey('category_id'), isTrue);
        expect(result.containsKey('categoryId'), isFalse);
      });
    });

    group('fromMap', () {
      test('should return a valid model when map contains all required fields', () {
        // Arrange
        // (map already defined above)

        // Act
        final result = ProductModel.fromMap(map);

        // Assert
        expect(result.id, 'prod-1');
        expect(result.name, 'Banana');
        expect(result.categoryId, 'cat-1');
        expect(result.unit, 'kg');
      });

      test('should read category_id from snake_case key in map', () {
        // Arrange
        final snakeCaseMap = <String, dynamic>{
          'id': 'prod-2',
          'name': 'Maca',
          'category_id': 'cat-5',
          'unit': 'un',
        };

        // Act
        final result = ProductModel.fromMap(snakeCaseMap);

        // Assert
        expect(result.categoryId, 'cat-5');
      });
    });

    group('toEntity', () {
      test('should return a Product entity with matching fields', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toEntity();

        // Assert
        expect(result.id, model.id);
        expect(result.name, model.name);
        expect(result.categoryId, model.categoryId);
        expect(result.unit, model.unit);
      });
    });

    group('fromEntity', () {
      test('should return a ProductModel with matching fields from entity', () {
        // Arrange
        // (entity already defined above)

        // Act
        final result = ProductModel.fromEntity(entity);

        // Assert
        expect(result.id, entity.id);
        expect(result.name, entity.name);
        expect(result.categoryId, entity.categoryId);
        expect(result.unit, entity.unit);
      });
    });

    group('round-trip', () {
      test('should preserve all data through entity -> model -> map -> model -> entity', () {
        // Arrange
        const originalEntity = Product(
          id: 'prod-rt',
          name: 'Round Trip Product',
          categoryId: 'cat-rt',
          unit: 'L',
        );

        // Act
        final modelFromEntity = ProductModel.fromEntity(originalEntity);
        final mapFromModel = modelFromEntity.toMap();
        final modelFromMap = ProductModel.fromMap(mapFromModel);
        final finalEntity = modelFromMap.toEntity();

        // Assert
        expect(finalEntity.id, originalEntity.id);
        expect(finalEntity.name, originalEntity.name);
        expect(finalEntity.categoryId, originalEntity.categoryId);
        expect(finalEntity.unit, originalEntity.unit);
      });

      test('should preserve all data through map -> model -> entity -> model -> map', () {
        // Arrange
        final originalMap = <String, dynamic>{
          'id': 'prod-rt2',
          'name': 'Map Round Trip Product',
          'category_id': 'cat-rt2',
          'unit': 'g',
        };

        // Act
        final modelFromMap = ProductModel.fromMap(originalMap);
        final entityFromModel = modelFromMap.toEntity();
        final modelFromEntity = ProductModel.fromEntity(entityFromModel);
        final finalMap = modelFromEntity.toMap();

        // Assert
        expect(finalMap['id'], originalMap['id']);
        expect(finalMap['name'], originalMap['name']);
        expect(finalMap['category_id'], originalMap['category_id']);
        expect(finalMap['unit'], originalMap['unit']);
      });
    });
  });
}
