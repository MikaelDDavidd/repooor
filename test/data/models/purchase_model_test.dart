import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/models/purchase_model.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';

void main() {
  group('PurchaseModel', () {
    const model = PurchaseModel(
      id: 'purchase-1',
      date: '2026-02-21T00:00:00.000',
      type: 'main',
    );

    final map = <String, dynamic>{
      'id': 'purchase-1',
      'date': '2026-02-21T00:00:00.000',
      'type': 'main',
    };

    group('toMap', () {
      test('should return a map with all fields correctly mapped', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toMap();

        // Assert
        expect(result['id'], 'purchase-1');
        expect(result['date'], '2026-02-21T00:00:00.000');
        expect(result['type'], 'main');
      });
    });

    group('fromMap', () {
      test('should return a valid model when map contains all required fields', () {
        // Arrange
        // (map already defined above)

        // Act
        final result = PurchaseModel.fromMap(map);

        // Assert
        expect(result.id, 'purchase-1');
        expect(result.date, '2026-02-21T00:00:00.000');
        expect(result.type, 'main');
      });

      test('should handle midMonth type correctly', () {
        // Arrange
        final midMonthMap = <String, dynamic>{
          'id': 'purchase-2',
          'date': '2026-03-15T00:00:00.000',
          'type': 'midMonth',
        };

        // Act
        final result = PurchaseModel.fromMap(midMonthMap);

        // Assert
        expect(result.type, 'midMonth');
      });
    });

    group('toEntity', () {
      test('should return a Purchase entity with parsed DateTime and PurchaseType', () {
        // Arrange
        // (model already defined above)

        // Act
        final result = model.toEntity();

        // Assert
        expect(result.id, model.id);
        expect(result.date, DateTime.parse(model.date));
        expect(result.type, PurchaseType.main);
        expect(result.items, isEmpty);
      });

      test('should include items when items parameter is provided', () {
        // Arrange
        const items = [
          PurchaseItem(
            id: 'pi-1',
            purchaseId: 'purchase-1',
            productId: 'prod-1',
            quantity: 2.0,
          ),
        ];

        // Act
        final result = model.toEntity(items: items);

        // Assert
        expect(result.items, items);
        expect(result.items.length, 1);
      });

      test('should parse midMonth type correctly when type is midMonth', () {
        // Arrange
        const midMonthModel = PurchaseModel(
          id: 'purchase-2',
          date: '2026-03-15T00:00:00.000',
          type: 'midMonth',
        );

        // Act
        final result = midMonthModel.toEntity();

        // Assert
        expect(result.type, PurchaseType.midMonth);
      });
    });

    group('fromEntity', () {
      test('should return a PurchaseModel with serialized date and type from entity', () {
        // Arrange
        final entity = Purchase(
          id: 'purchase-1',
          date: DateTime(2026, 2, 21),
          type: PurchaseType.main,
        );

        // Act
        final result = PurchaseModel.fromEntity(entity);

        // Assert
        expect(result.id, entity.id);
        expect(result.date, entity.date.toIso8601String());
        expect(result.type, 'main');
      });

      test('should serialize midMonth type as string when entity type is midMonth', () {
        // Arrange
        final entity = Purchase(
          id: 'purchase-2',
          date: DateTime(2026, 3, 15),
          type: PurchaseType.midMonth,
        );

        // Act
        final result = PurchaseModel.fromEntity(entity);

        // Assert
        expect(result.type, 'midMonth');
      });
    });

    group('round-trip', () {
      test('should preserve all data through entity -> model -> map -> model -> entity', () {
        // Arrange
        final originalEntity = Purchase(
          id: 'purchase-rt',
          date: DateTime(2026, 6, 15, 10, 30),
          type: PurchaseType.midMonth,
        );

        // Act
        final modelFromEntity = PurchaseModel.fromEntity(originalEntity);
        final mapFromModel = modelFromEntity.toMap();
        final modelFromMap = PurchaseModel.fromMap(mapFromModel);
        final finalEntity = modelFromMap.toEntity();

        // Assert
        expect(finalEntity.id, originalEntity.id);
        expect(finalEntity.date, originalEntity.date);
        expect(finalEntity.type, originalEntity.type);
      });

      test('should preserve all data through map -> model -> entity -> model -> map', () {
        // Arrange
        final originalMap = <String, dynamic>{
          'id': 'purchase-rt2',
          'date': '2026-08-01T14:00:00.000',
          'type': 'main',
        };

        // Act
        final modelFromMap = PurchaseModel.fromMap(originalMap);
        final entityFromModel = modelFromMap.toEntity();
        final modelFromEntity = PurchaseModel.fromEntity(entityFromModel);
        final finalMap = modelFromEntity.toMap();

        // Assert
        expect(finalMap['id'], originalMap['id']);
        expect(finalMap['date'], originalMap['date']);
        expect(finalMap['type'], originalMap['type']);
      });

      test('should preserve DateTime precision through serialization round-trip', () {
        // Arrange
        final originalDate = DateTime(2026, 12, 25, 18, 45, 30, 123);
        final entity = Purchase(
          id: 'purchase-dt',
          date: originalDate,
          type: PurchaseType.main,
        );

        // Act
        final model = PurchaseModel.fromEntity(entity);
        final restored = model.toEntity();

        // Assert
        expect(restored.date.year, originalDate.year);
        expect(restored.date.month, originalDate.month);
        expect(restored.date.day, originalDate.day);
        expect(restored.date.hour, originalDate.hour);
        expect(restored.date.minute, originalDate.minute);
        expect(restored.date.second, originalDate.second);
        expect(restored.date.millisecond, originalDate.millisecond);
      });
    });
  });
}
