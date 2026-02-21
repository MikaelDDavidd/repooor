import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_ds.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._dataSource);

  final ProductLocalDs _dataSource;

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
  }

  @override
  Future<void> update(Product product) async {
    await _dataSource.update(ProductModel.fromEntity(product));
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }
}
