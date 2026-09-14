import '../../domain/entities/purchase.dart';
import '../../domain/entities/purchase_item.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_local_ds.dart';
import '../models/purchase_model.dart';
import '../models/purchase_item_model.dart';
import '../sync/sync_entities.dart';
import '../sync/sync_recorder.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl(this._dataSource, this._sync);

  final PurchaseLocalDs _dataSource;
  final SyncRecorder _sync;

  @override
  Future<List<Purchase>> getAll() async {
    final models = await _dataSource.getAll();
    final purchases = <Purchase>[];
    for (final model in models) {
      final itemModels = await _dataSource.getItemsByPurchaseId(model.id);
      final items = itemModels.map((m) => m.toEntity()).toList();
      purchases.add(model.toEntity(items: items));
    }
    return purchases;
  }

  @override
  Future<Purchase?> getById(String id) async {
    final model = await _dataSource.getById(id);
    if (model == null) return null;
    final itemModels = await _dataSource.getItemsByPurchaseId(id);
    final items = itemModels.map((m) => m.toEntity()).toList();
    return model.toEntity(items: items);
  }

  @override
  Future<void> create(Purchase purchase) async {
    await _dataSource.insert(PurchaseModel.fromEntity(purchase));
    await _sync.recordUpsert(SyncEntities.purchases, purchase.id);
    for (final item in purchase.items) {
      await _dataSource.insertItem(PurchaseItemModel.fromEntity(item));
      await _sync.recordUpsert(SyncEntities.purchaseItems, item.id);
    }
  }

  @override
  Future<void> updateStatus(String id, PurchaseStatus status) async {
    await _dataSource.updateStatus(id, status.name);
    await _sync.recordUpsert(SyncEntities.purchases, id);
  }

  // Os itens somem junto com a compra no sqflite, então cada um precisa da
  // sua própria operação para a exclusão chegar ao Appwrite.
  @override
  Future<void> delete(String id) async {
    final items = await _dataSource.getItemsByPurchaseId(id);
    await _dataSource.delete(id);
    for (final item in items) {
      await _sync.recordDelete(SyncEntities.purchaseItems, item.id);
    }
    await _sync.recordDelete(SyncEntities.purchases, id);
  }

  @override
  Future<List<Purchase>> getByDateRange(DateTime start, DateTime end) async {
    final models = await _dataSource.getByDateRange(
      start.toIso8601String(),
      end.toIso8601String(),
    );
    final purchases = <Purchase>[];
    for (final model in models) {
      final itemModels = await _dataSource.getItemsByPurchaseId(model.id);
      final items = itemModels.map((m) => m.toEntity()).toList();
      purchases.add(model.toEntity(items: items));
    }
    return purchases;
  }

  @override
  Future<List<PurchaseItem>> getAllItemsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final models = await _dataSource.getAllItemsByDateRange(
      start.toIso8601String(),
      end.toIso8601String(),
    );
    return models.map((m) => m.toEntity()).toList();
  }
}

class PurchaseItemRepositoryImpl implements PurchaseItemRepository {
  PurchaseItemRepositoryImpl(this._dataSource, this._sync);

  final PurchaseLocalDs _dataSource;
  final SyncRecorder _sync;

  @override
  Future<void> addItem(PurchaseItem item) async {
    await _dataSource.insertItem(PurchaseItemModel.fromEntity(item));
    await _sync.recordUpsert(SyncEntities.purchaseItems, item.id);
  }

  @override
  Future<void> removeItem(String itemId) async {
    await _dataSource.deleteItem(itemId);
    await _sync.recordDelete(SyncEntities.purchaseItems, itemId);
  }

  @override
  Future<void> updateItem(PurchaseItem item) async {
    await _dataSource.updateItem(PurchaseItemModel.fromEntity(item));
    await _sync.recordUpsert(SyncEntities.purchaseItems, item.id);
  }
}
