import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAll();
  Future<Category?> getById(String id);
  Future<void> create(Category category);
  Future<void> update(Category category);
  Future<void> delete(String id);
  Future<void> seedDefaults();
}
