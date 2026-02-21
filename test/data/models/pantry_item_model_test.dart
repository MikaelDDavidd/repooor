import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/models/pantry_item_model.dart';
import 'package:repooor/domain/entities/pantry_item.dart';

void main() {
  group('PantryItemModel', () {
    const model = PantryItemModel(
      id: 'pantry-1',
      productId: 'prod-1',
      currentQuantity: 3.0,
      idealQuantity: 10.0,
    );

    final map = <String, dynamic>{
      'id': 'pantry-1',
      'product_id': 'prod-1',
      'current_quantity': 3.0,
      'ideal_quantity': 10.0,
    };

    const entity = PantryItem(
      id: 'pantry-1',
      productId: 'prod-1',
      currentQuantity: 3.0,
      idealQuantity: 10.0,
    );

    group('toMap', () {
      test('should return a map with all fields correctly mapped', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toMap();

        // Assert
        expect(result['id'], 'pantry-1');
        expect(result['product_id'], 'prod-1');
        expect(result['current_quantity'], 3.0);
        expect(result['ideal_quantity'], 10.0);
      });

      test('should use snake_case keys for camelCase fields', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toMap();

        // Assert
        expect(result.containsKey('product_id'), isTrue);
        expect(result.containsKey('current_quantity'), isTrue);
        expect(result.containsKey('ideal_quantity'), isTrue);
        expect(result.containsKey('productId'), isFalse);
        expect(result.containsKey('currentQuantity'), isFalse);
        expect(result.containsKey('idealQuantity'), isFalse);
      });
    });

    group('fromMap', () {
      test('should return a valid model when map contains all required fields', () {
        // Arrange
        // (map already defined above)

        // Act
        final result = PantryItemModel.fromMap(map);

        // Assert
        expect(result.id, 'pantry-1');
        expect(result.productId, 'prod-1');
        expect(result.currentQuantity, 3.0);
        expect(result.idealQuantity, 10.0);
      });

      test('should handle int values for quantity fields when map has int types', () {
        // Arrange
        final intMap = <String, dynamic>{
          'id': 'pantry-2',
          'product_id': 'prod-2',
          'current_quantity': 5,
          'ideal_quantity': 12,
        };

        // Act
        final result = PantryItemModel.fromMap(intMap);

        // Assert
        expect(result.currentQuantity, 5.0);
        expect(result.idealQuantity, 12.0);
        expect(result.currentQuantity, isA<double>());
        expect(result.idealQuantity, isA<double>());
      });
    });

    group('toEntity', () {
      test('should return a PantryItem entity with matching fields', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toEntity();

        // Assert
        expect(result.id, model.id);
        expect(result.productId, model.productId);
        expect(result.currentQuantity, model.currentQuantity);
        expect(result.idealQuantity, model.idealQuantity);
      });
    });

    group('fromEntity', () {
      test('should return a PantryItemModel with matching fields from entity', () {
        // Arrange
        // (entity already defined above)

        // Act
        final result = PantryItemModel.fromEntity(entity);

        // Assert
        expect(result.id, entity.id);
        expect(result.productId, entity.productId);
        expect(result.currentQuantity, entity.currentQuantity);
        expect(result.idealQuantity, entity.idealQuantity);
      });
    });

    group('round-trip', () {
      test('should preserve all data through entity -> model -> map -> model -> entity', () {
        // Arrange
        const originalEntity = PantryItem(
          id: 'pantry-rt',
          productId: 'prod-rt',
          currentQuantity: 4.5,
          idealQuantity: 8.0,
        );

        // Act
        final modelFromEntity = PantryItemModel.fromEntity(originalEntity);
        final mapFromModel = modelFromEntity.toMap();
        final modelFromMap = PantryItemModel.fromMap(mapFromModel);
        final finalEntity = modelFromMap.toEntity();

        // Assert
        expect(finalEntity.id, originalEntity.id);
        expect(finalEntity.productId, originalEntity.productId);
        expect(finalEntity.currentQuantity, originalEntity.currentQuantity);
        expect(finalEntity.idealQuantity, originalEntity.idealQuantity);
      });

      test('should preserve all data through map -> model -> entity -> model -> map', () {
        // Arrange
        final originalMap = <String, dynamic>{
          'id': 'pantry-rt2',
          'product_id': 'prod-rt2',
          'current_quantity': 1.5,
          'ideal_quantity': 6.0,
        };

        // Act
        final modelFromMap = PantryItemModel.fromMap(originalMap);
        final entityFromModel = modelFromMap.toEntity();
        final modelFromEntity = PantryItemModel.fromEntity(entityFromModel);
        final finalMap = modelFromEntity.toMap();

        // Assert
        expect(finalMap['id'], originalMap['id']);
        expect(finalMap['product_id'], originalMap['product_id']);
        expect(finalMap['current_quantity'], originalMap['current_quantity']);
        expect(finalMap['ideal_quantity'], originalMap['ideal_quantity']);
      });
    });
  });
}
