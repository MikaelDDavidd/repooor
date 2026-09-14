import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';

void main() {
  group('Purchase', () {
    final date = DateTime(2026, 2, 21);
    final purchase = Purchase(
      id: 'purchase-1',
      date: date,
      type: PurchaseType.main,
      items: const [
        PurchaseItem(
          id: 'pi-1',
          purchaseId: 'purchase-1',
          productId: 'prod-1',
          quantity: 2.0,
        ),
        PurchaseItem(
          id: 'pi-2',
          purchaseId: 'purchase-1',
          productId: 'prod-2',
          quantity: 5.0,
        ),
      ],
    );

    group('copyWith', () {
      test('should return identical entity when no parameters are passed', () {
        // Arrange
        // (purchase already defined above)

        // Act
        final result = purchase.copyWith();

        // Assert
        expect(result.id, purchase.id);
        expect(result.date, purchase.date);
        expect(result.type, purchase.type);
        expect(result.items, purchase.items);
      });

      test('should return entity with updated id when id is passed', () {
        // Arrange
        const newId = 'purchase-99';

        // Act
        final result = purchase.copyWith(id: newId);

        // Assert
        expect(result.id, newId);
        expect(result.date, purchase.date);
        expect(result.type, purchase.type);
        expect(result.items, purchase.items);
      });

      test('should return entity with updated date when date is passed', () {
        // Arrange
        final newDate = DateTime(2026, 3, 15);

        // Act
        final result = purchase.copyWith(date: newDate);

        // Assert
        expect(result.date, newDate);
        expect(result.id, purchase.id);
      });

      test('should return entity with updated type when type is passed', () {
        // Arrange
        const newType = PurchaseType.midMonth;

        // Act
        final result = purchase.copyWith(type: newType);

        // Assert
        expect(result.type, newType);
        expect(result.id, purchase.id);
      });

      test('should return entity with updated items when items is passed', () {
        // Arrange
        const newItems = <PurchaseItem>[];

        // Act
        final result = purchase.copyWith(items: newItems);

        // Assert
        expect(result.items, newItems);
        expect(result.id, purchase.id);
      });

      test(
        'should return entity with all fields updated when all parameters are passed',
        () {
          // Arrange
          const newId = 'purchase-2';
          final newDate = DateTime(2026, 6, 1);
          const newType = PurchaseType.midMonth;
          const newItems = <PurchaseItem>[
            PurchaseItem(
              id: 'pi-3',
              purchaseId: 'purchase-2',
              productId: 'prod-3',
              quantity: 1.0,
            ),
          ];

          // Act
          final result = purchase.copyWith(
            id: newId,
            date: newDate,
            type: newType,
            items: newItems,
          );

          // Assert
          expect(result.id, newId);
          expect(result.date, newDate);
          expect(result.type, newType);
          expect(result.items, newItems);
        },
      );
    });

    group('totalItems', () {
      test('should return item count when purchase has items', () {
        // Arrange
        // (purchase already defined above with 2 items)

        // Act
        final result = purchase.totalItems;

        // Assert
        expect(result, 2);
      });

      test('should return 0 when purchase has no items', () {
        // Arrange
        final emptyPurchase = Purchase(
          id: 'purchase-empty',
          date: date,
          type: PurchaseType.main,
        );

        // Act
        final result = emptyPurchase.totalItems;

        // Assert
        expect(result, 0);
      });
    });

    group('totalPrice', () {
      test('should return null when no item has unitPrice', () {
        expect(purchase.totalPrice, isNull);
      });

      test('should sum totalPrice of items that have unitPrice', () {
        final priced = Purchase(
          id: 'p',
          date: date,
          type: PurchaseType.main,
          items: const [
            PurchaseItem(
              id: 'a',
              purchaseId: 'p',
              productId: 'x',
              quantity: 2,
              unitPrice: 3,
            ),
            PurchaseItem(
              id: 'b',
              purchaseId: 'p',
              productId: 'y',
              quantity: 1,
              unitPrice: 5.5,
            ),
            PurchaseItem(id: 'c', purchaseId: 'p', productId: 'z', quantity: 4),
          ],
        );
        expect(priced.totalPrice, 11.5);
        expect(priced.pricedItemCount, 2);
      });
    });

    group('default values', () {
      test('should default to empty list when items is not provided', () {
        // Arrange & Act
        final purchase = Purchase(
          id: 'purchase-default',
          date: date,
          type: PurchaseType.midMonth,
        );

        // Assert
        expect(purchase.items, isEmpty);
        expect(purchase.totalItems, 0);
      });
    });
  });
}
