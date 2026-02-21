import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CreateCategory {
  CreateCategory(this._repository);

  final CategoryRepository _repository;

  Future<void> call(Category category) => _repository.create(category);
}
