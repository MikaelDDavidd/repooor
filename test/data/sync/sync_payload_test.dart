import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/sync/sync_payload.dart';

void main() {
  test('should translate the product columns to the remote names', () {
    final data = SyncPayload.fromRow('products', {
      'id': 'prod-1',
      'name': 'Arroz',
      'category_id': 'cat-1',
      'unit': 'kg',
      'updated_at': 1750000000000,
    });

    expect(data, {
      'name': 'Arroz',
      'categoryId': 'cat-1',
      'unit': 'kg',
      'updatedAt': 1750000000000,
    });
  });

  test('should send picked as a boolean and keep the optional prices', () {
    final data = SyncPayload.fromRow('purchase_items', {
      'id': 'item-1',
      'purchase_id': 'purchase-1',
      'product_id': 'prod-1',
      'quantity': 2.0,
      'unit_price': 9.9,
      'planned_quantity': null,
      'planned_unit_price': null,
      'picked': 1,
      'updated_at': 1750000000000,
    });

    expect(data!['picked'], isTrue);
    expect(data['purchaseId'], 'purchase-1');
    expect(data['unitPrice'], 9.9);
    expect(data['plannedQuantity'], isNull);
    expect(data.containsKey('id'), isFalse);
  });

  test('should send picked false when the item was not picked', () {
    final data = SyncPayload.fromRow('purchase_items', {
      'id': 'item-1',
      'purchase_id': 'purchase-1',
      'product_id': 'prod-1',
      'quantity': 1.0,
      'picked': 0,
      'updated_at': 1750000000000,
    });

    expect(data!['picked'], isFalse);
  });

  test('should map the pantry quantities', () {
    final data = SyncPayload.fromRow('pantry_items', {
      'id': 'pantry-1',
      'product_id': 'prod-1',
      'current_quantity': 3.0,
      'ideal_quantity': 5.0,
      'updated_at': 1750000000000,
    });

    expect(data, {
      'productId': 'prod-1',
      'currentQuantity': 3.0,
      'idealQuantity': 5.0,
      'updatedAt': 1750000000000,
    });
  });

  test('should return null for a table that is not synced', () {
    expect(SyncPayload.fromRow('sync_queue', {'id': 'x'}), isNull);
  });

  test('should fall back to now when the row has no updated_at', () {
    final data = SyncPayload.fromRow('categories', {
      'id': 'cat-1',
      'name': 'Mercearia',
      'icon': 100,
      'color': 200,
      'updated_at': null,
    });

    expect(data!['updatedAt'], isA<int>());
    expect(data['updatedAt'], greaterThan(0));
  });
}
