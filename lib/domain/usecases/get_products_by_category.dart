import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsByCategory {
  GetProductsByCategory(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call(String categoryId) =>
      _repository.getByCategory(categoryId);
}
