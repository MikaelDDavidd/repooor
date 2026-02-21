import '../entities/pantry_item.dart';

abstract class PantryRepository {
  Future<List<PantryItem>> getAll();
  Future<PantryItem?> getByProductId(String productId);
  Future<void> add(PantryItem item);
  Future<void> updateQuantity(String id, double currentQuantity);
  Future<void> updateIdealQuantity(String id, double idealQuantity);
  Future<void> remove(String id);
  Future<List<PantryItem>> getLowStockItems();
}
