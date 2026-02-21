import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  UpdateProduct(this._repository);

  final ProductRepository _repository;

  Future<void> call(Product product) => _repository.update(product);
}
