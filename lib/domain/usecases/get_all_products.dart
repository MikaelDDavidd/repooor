import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetAllProducts {
  GetAllProducts(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call() => _repository.getAll();
}
