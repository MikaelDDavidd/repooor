import '../entities/purchase.dart';
import '../entities/purchase_item.dart';

abstract class PurchaseRepository {
  Future<List<Purchase>> getAll();
  Future<Purchase?> getById(String id);
  Future<void> create(Purchase purchase);
  Future<void> addItem(PurchaseItem item);
  Future<void> removeItem(String itemId);
  Future<void> updateItem(PurchaseItem item);
  Future<void> delete(String id);
}
