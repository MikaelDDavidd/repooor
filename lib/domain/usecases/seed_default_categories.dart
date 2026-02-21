import '../repositories/category_repository.dart';

class SeedDefaultCategories {
  SeedDefaultCategories(this._repository);

  final CategoryRepository _repository;

  Future<void> call() => _repository.seedDefaults();
}
