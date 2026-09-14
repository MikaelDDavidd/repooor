import 'package:uuid/uuid.dart';
import '../../core/constants/default_categories.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_ds.dart';
import '../models/category_model.dart';
import '../sync/sync_entities.dart';
import '../sync/sync_recorder.dart';

const _uuid = Uuid();

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dataSource, this._sync);

  final CategoryLocalDs _dataSource;
  final SyncRecorder _sync;

  @override
  Future<List<Category>> getAll() async {
    final models = await _dataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Category?> getById(String id) async {
    final model = await _dataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<void> create(Category category) async {
    await _dataSource.insert(CategoryModel.fromEntity(category));
    await _sync.recordUpsert(SyncEntities.categories, category.id);
  }

  @override
  Future<void> update(Category category) async {
    await _dataSource.update(CategoryModel.fromEntity(category));
    await _sync.recordUpsert(SyncEntities.categories, category.id);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
    await _sync.recordDelete(SyncEntities.categories, id);
  }

  @override
  Future<void> seedDefaults() async {
    final models = defaultCategories
        .map(
          (dc) => CategoryModel(
            id: _uuid.v4(),
            name: dc.name,
            icon: dc.icon.codePoint,
            color: dc.color.toARGB32(),
          ),
        )
        .toList();
    await _dataSource.insertBatch(models);
    await _sync.recordUpsertAll(
      SyncEntities.categories,
      models.map((m) => m.id),
    );
  }
}
