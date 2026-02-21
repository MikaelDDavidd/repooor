import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_all_categories.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/seed_default_categories.dart';
import '../../core/di/providers.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  GetAllCategories get _getAll => ref.watch(getAllCategoriesProvider);
  CreateCategory get _create => ref.watch(createCategoryProvider);
  UpdateCategory get _update => ref.watch(updateCategoryProvider);
  DeleteCategory get _delete => ref.watch(deleteCategoryProvider);
  SeedDefaultCategories get _seed => ref.watch(seedDefaultCategoriesProvider);

  @override
  Future<List<Category>> build() async {
    final categories = await _getAll();
    if (categories.isEmpty) {
      await _seed();
      return _getAll();
    }
    return categories;
  }

  Future<void> add(String name, int icon, int color) async {
    final category = Category(id: _uuid.v4(), name: name, icon: icon, color: color);
    await _create(category);
    ref.invalidateSelf();
  }

  Future<void> edit(Category category) async {
    await _update(category);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await _delete(id);
    ref.invalidateSelf();
  }
}
