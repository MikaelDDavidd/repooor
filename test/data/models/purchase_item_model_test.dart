import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/models/purchase_item_model.dart';
import 'package:repooor/domain/entities/purchase_item.dart';

void main() {
  group('PurchaseItemModel', () {
    const model = PurchaseItemModel(
      id: 'pi-1',
      purchaseId: 'purchase-1',
      productId: 'prod-1',
      quantity: 3.5,
    );

    final map = <String, dynamic>{
      'id': 'pi-1',
      'purchase_id': 'purchase-1',
      'product_id': 'prod-1',
      'quantity': 3.5,
    };

    const entity = PurchaseItem(
      id: 'pi-1',
      purchaseId: 'purchase-1',
      productId: 'prod-1',
      quantity: 3.5,
    );

    group('toMap', () {
      test('should return a map with all fields correctly mapped', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toMap();

        // Assert
        expect(result['id'], 'pi-1');
        expect(result['purchase_id'], 'purchase-1');
        expect(result['product_id'], 'prod-1');
        expect(result['quantity'], 3.5);
      });

      test('should use snake_case keys for camelCase fields', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toMap();

        // Assert
        expect(result.containsKey('purchase_id'), isTrue);
        expect(result.containsKey('product_id'), isTrue);
        expect(result.containsKey('purchaseId'), isFalse);
        expect(result.containsKey('productId'), isFalse);
      });
    });

    group('fromMap', () {
      test(
        'should return a valid model when map contains all required fields',
        () {
          // Arrange
          // (map already defined above)

          // Act
          final result = PurchaseItemModel.fromMap(map);

          // Assert
          expect(result.id, 'pi-1');
          expect(result.purchaseId, 'purchase-1');
          expect(result.productId, 'prod-1');
          expect(result.quantity, 3.5);
        },
      );

      test('should handle int value for quantity when map has int type', () {
        // Arrange
        final intMap = <String, dynamic>{
          'id': 'pi-2',
          'purchase_id': 'purchase-2',
          'product_id': 'prod-2',
          'quantity': 5,
        };

        // Act
        final result = PurchaseItemModel.fromMap(intMap);

        // Assert
        expect(result.quantity, 5.0);
        expect(result.quantity, isA<double>());
      });
    });

    group('toEntity', () {
      test('should return a PurchaseItem entity with matching fields', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toEntity();

        // Assert
        expect(result.id, model.id);
        expect(result.purchaseId, model.purchaseId);
        expect(result.productId, model.productId);
        expect(result.quantity, model.quantity);
      });
    });

    group('fromEntity', () {
      test(
        'should return a PurchaseItemModel with matching fields from entity',
        () {
          // Arrange
          // (entity already defined above)

          // Act
          final result = PurchaseItemModel.fromEntity(entity);

          // Assert
          expect(result.id, entity.id);
          expect(result.purchaseId, entity.purchaseId);
          expect(result.productId, entity.productId);
          expect(result.quantity, entity.quantity);
        },
      );
    });

    group('round-trip', () {
      test(
        'should preserve all data through entity -> model -> map -> model -> entity',
        () {
          // Arrange
          const originalEntity = PurchaseItem(
            id: 'pi-rt',
            purchaseId: 'purchase-rt',
            productId: 'prod-rt',
            quantity: 7.25,
          );

          // Act
          final modelFromEntity = PurchaseItemModel.fromEntity(originalEntity);
          final mapFromModel = modelFromEntity.toMap();
          final modelFromMap = PurchaseItemModel.fromMap(mapFromModel);
          final finalEntity = modelFromMap.toEntity();

          // Assert
          expect(finalEntity.id, originalEntity.id);
          expect(finalEntity.purchaseId, originalEntity.purchaseId);
          expect(finalEntity.productId, originalEntity.productId);
          expect(finalEntity.quantity, originalEntity.quantity);
        },
      );

      test(
        'should preserve all data through map -> model -> entity -> model -> map',
        () {
          // Arrange
          final originalMap = <String, dynamic>{
            'id': 'pi-rt2',
            'purchase_id': 'purchase-rt2',
            'product_id': 'prod-rt2',
            'quantity': 0.75,
          };

          // Act
          final modelFromMap = PurchaseItemModel.fromMap(originalMap);
          final entityFromModel = modelFromMap.toEntity();
          final modelFromEntity = PurchaseItemModel.fromEntity(entityFromModel);
          final finalMap = modelFromEntity.toMap();

          // Assert
          expect(finalMap['id'], originalMap['id']);
          expect(finalMap['purchase_id'], originalMap['purchase_id']);
          expect(finalMap['product_id'], originalMap['product_id']);
          expect(finalMap['quantity'], originalMap['quantity']);
        },
      );
    });

    group('unitPrice', () {
      test('toMap should include null unit_price when not provided', () {
        const m = PurchaseItemModel(
          id: 'pi',
          purchaseId: 'p',
          productId: 'prod',
          quantity: 1,
        );
        expect(m.toMap()['unit_price'], isNull);
      });

      test('toMap should serialize unit_price when provided', () {
        const m = PurchaseItemModel(
          id: 'pi',
          purchaseId: 'p',
          productId: 'prod',
          quantity: 2,
          unitPrice: 3.49,
        );
        expect(m.toMap()['unit_price'], 3.49);
      });

      test('fromMap should parse null unit_price as null', () {
        final result = PurchaseItemModel.fromMap({
          'id': 'pi',
          'purchase_id': 'p',
          'product_id': 'prod',
          'quantity': 1.0,
          'unit_price': null,
        });
        expect(result.unitPrice, isNull);
      });

      test('fromMap should parse int unit_price as double', () {
        final result = PurchaseItemModel.fromMap({
          'id': 'pi',
          'purchase_id': 'p',
          'product_id': 'prod',
          'quantity': 1.0,
          'unit_price': 5,
        });
        expect(result.unitPrice, 5.0);
        expect(result.unitPrice, isA<double>());
      });

      test('round-trip should preserve unitPrice', () {
        const originalEntity = PurchaseItem(
          id: 'pi',
          purchaseId: 'p',
          productId: 'prod',
          quantity: 2,
          unitPrice: 4.75,
        );

        final modelFromEntity = PurchaseItemModel.fromEntity(originalEntity);
        final mapFromModel = modelFromEntity.toMap();
        final modelFromMap = PurchaseItemModel.fromMap(mapFromModel);
        final finalEntity = modelFromMap.toEntity();

        expect(finalEntity.unitPrice, 4.75);
        expect(finalEntity.totalPrice, 9.5);
      });
    });
  });
}
