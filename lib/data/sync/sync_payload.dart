import '../models/category_model.dart';
import '../models/pantry_item_model.dart';
import '../models/product_model.dart';
import '../models/purchase_item_model.dart';
import '../models/purchase_model.dart';

abstract final class SyncPayload {
  static Map<String, dynamic>? fromRow(
    String entity,
    Map<String, dynamic> row,
  ) {
    final updatedAt =
        (row['updated_at'] as num?)?.toInt() ??
        DateTime.now().millisecondsSinceEpoch;
    return switch (entity) {
      'categories' => CategoryModel.fromMap(
        row,
      ).toRemoteMap(updatedAt: updatedAt),
      'products' => ProductModel.fromMap(row).toRemoteMap(updatedAt: updatedAt),
      'pantry_items' => PantryItemModel.fromMap(
        row,
      ).toRemoteMap(updatedAt: updatedAt),
      'purchases' => PurchaseModel.fromMap(
        row,
      ).toRemoteMap(updatedAt: updatedAt),
      'purchase_items' => PurchaseItemModel.fromMap(
        row,
      ).toRemoteMap(updatedAt: updatedAt),
      _ => null,
    };
  }
}
