import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<List<Product>> getByCategory(String categoryId);
  Future<List<Product>> search(String query);
  Future<Product?> getById(String id);
  Future<void> create(Product product);
  Future<void> update(Product product);
  Future<void> delete(String id);
}
