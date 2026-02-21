import '../../domain/entities/pantry_item.dart';
import '../../domain/repositories/pantry_repository.dart';
import '../datasources/pantry_local_ds.dart';
import '../models/pantry_item_model.dart';

class PantryRepositoryImpl implements PantryRepository {
  PantryRepositoryImpl(this._dataSource);

  final PantryLocalDs _dataSource;

  @override
  Future<List<PantryItem>> getAll() async {
    final models = await _dataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<PantryItem?> getByProductId(String productId) async {
    final model = await _dataSource.getByProductId(productId);
    return model?.toEntity();
  }

  @override
  Future<void> add(PantryItem item) async {
    await _dataSource.insert(PantryItemModel.fromEntity(item));
  }

  @override
  Future<void> updateQuantity(String id, double currentQuantity) async {
    await _dataSource.updateQuantity(id, currentQuantity);
  }

  @override
  Future<void> updateIdealQuantity(String id, double idealQuantity) async {
    await _dataSource.updateIdealQuantity(id, idealQuantity);
  }

  @override
  Future<void> remove(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<List<PantryItem>> getLowStockItems() async {
    final models = await _dataSource.getLowStock();
    return models.map((m) => m.toEntity()).toList();
  }
}
