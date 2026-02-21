import '../entities/purchase.dart';
import '../entities/purchase_item.dart';

abstract class PurchaseRepository {
  Future<List<Purchase>> getAll();
  Future<Purchase?> getById(String id);
  Future<List<Purchase>> getByDateRange(DateTime start, DateTime end);
  Future<List<PurchaseItem>> getAllItemsByDateRange(DateTime start, DateTime end);
  Future<void> create(Purchase purchase);
  Future<void> delete(String id);
}

abstract class PurchaseItemRepository {
  Future<void> addItem(PurchaseItem item);
  Future<void> removeItem(String itemId);
  Future<void> updateItem(PurchaseItem item);
}
