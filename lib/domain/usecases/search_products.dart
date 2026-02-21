import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SearchProducts {
  SearchProducts(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call(String query) => _repository.search(query);
}
