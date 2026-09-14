import '../entities/category.dart';
import '../repositories/product_repository.dart';

class SeedDefaultProducts {
  SeedDefaultProducts(this._repository);

  final ProductRepository _repository;

  Future<void> call(List<Category> categories) =>
      _repository.seedDefaults(categories);
}
