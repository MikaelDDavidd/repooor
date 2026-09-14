import 'package:uuid/uuid.dart';
import '../../core/constants/default_products.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_ds.dart';
import '../models/product_model.dart';
import '../sync/sync_entities.dart';
import '../sync/sync_recorder.dart';

const _uuid = Uuid();

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._dataSource, this._sync);

  final ProductLocalDs _dataSource;
  final SyncRecorder _sync;

  @override
  Future<List<Product>> getAll() async {
    final models = await _dataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Product>> getByCategory(String categoryId) async {
    final models = await _dataSource.getByCategory(categoryId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Product>> search(String query) async {
    final models = await _dataSource.search(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Product?> getById(String id) async {
    final model = await _dataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<void> create(Product product) async {
    await _dataSource.insert(ProductModel.fromEntity(product));
    await _sync.recordUpsert(SyncEntities.products, product.id);
  }

  @override
  Future<void> update(Product product) async {
    await _dataSource.update(ProductModel.fromEntity(product));
    await _sync.recordUpsert(SyncEntities.products, product.id);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
    await _sync.recordDelete(SyncEntities.products, id);
  }

  @override
  Future<void> seedDefaults(List<Category> categories) async {
    final byName = {for (final c in categories) c.name: c.id};
    final fallbackId = byName['Outros'];
    final models = <ProductModel>[];
    for (final dp in defaultProducts) {
      final categoryId = byName[dp.categoryName] ?? fallbackId;
      if (categoryId == null) continue;
      models.add(
        ProductModel(
          id: _uuid.v4(),
          name: dp.name,
          categoryId: categoryId,
          unit: dp.unit.label,
        ),
      );
    }
    await _dataSource.insertBatch(models);
    await _sync.recordUpsertAll(SyncEntities.products, models.map((m) => m.id));
  }
}
