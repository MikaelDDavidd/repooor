import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/domain/entities/purchase_item.dart';

void main() {
  group('PurchaseItem', () {
    const item = PurchaseItem(
      id: 'pi-1',
      purchaseId: 'purchase-1',
      productId: 'prod-1',
      quantity: 3.5,
    );

    group('copyWith', () {
      test('should return identical entity when no parameters are passed', () {
        // Arrange
        // (item already defined above)

        // Act
        final result = item.copyWith();

        // Assert
        expect(result.id, item.id);
        expect(result.purchaseId, item.purchaseId);
        expect(result.productId, item.productId);
        expect(result.quantity, item.quantity);
      });

      test('should return entity with updated id when id is passed', () {
        // Arrange
        const newId = 'pi-99';

        // Act
        final result = item.copyWith(id: newId);

        // Assert
        expect(result.id, newId);
        expect(result.purchaseId, item.purchaseId);
        expect(result.productId, item.productId);
        expect(result.quantity, item.quantity);
      });

      test('should return entity with updated purchaseId when purchaseId is passed', () {
        // Arrange
        const newPurchaseId = 'purchase-42';

        // Act
        final result = item.copyWith(purchaseId: newPurchaseId);

        // Assert
        expect(result.purchaseId, newPurchaseId);
        expect(result.id, item.id);
      });

      test('should return entity with updated productId when productId is passed', () {
        // Arrange
        const newProductId = 'prod-99';

        // Act
        final result = item.copyWith(productId: newProductId);

        // Assert
        expect(result.productId, newProductId);
        expect(result.id, item.id);
      });

      test('should return entity with updated quantity when quantity is passed', () {
        // Arrange
        const newQuantity = 10.0;

        // Act
        final result = item.copyWith(quantity: newQuantity);

        // Assert
        expect(result.quantity, newQuantity);
        expect(result.id, item.id);
      });

      test('should return entity with all fields updated when all parameters are passed', () {
        // Arrange
        const newId = 'pi-2';
        const newPurchaseId = 'purchase-2';
        const newProductId = 'prod-2';
        const newQuantity = 7.0;

        // Act
        final result = item.copyWith(
          id: newId,
          purchaseId: newPurchaseId,
          productId: newProductId,
          quantity: newQuantity,
        );

        // Assert
        expect(result.id, newId);
        expect(result.purchaseId, newPurchaseId);
        expect(result.productId, newProductId);
        expect(result.quantity, newQuantity);
      });
    });
  });
}
