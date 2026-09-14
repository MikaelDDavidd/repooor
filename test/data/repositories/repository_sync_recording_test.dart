import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/data/datasources/pantry_local_ds.dart';
import 'package:repooor/data/datasources/product_local_ds.dart';
import 'package:repooor/data/datasources/purchase_local_ds.dart';
import 'package:repooor/data/models/pantry_item_model.dart';
import 'package:repooor/data/models/product_model.dart';
import 'package:repooor/data/models/purchase_item_model.dart';
import 'package:repooor/data/models/purchase_model.dart';
import 'package:repooor/data/repositories/pantry_repository_impl.dart';
import 'package:repooor/data/repositories/product_repository_impl.dart';
import 'package:repooor/data/repositories/purchase_repository_impl.dart';
import 'package:repooor/data/sync/sync_entities.dart';
import 'package:repooor/data/sync/sync_recorder.dart';
import 'package:repooor/domain/entities/pantry_item.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';

class _MockProductLocalDs extends Mock implements ProductLocalDs {}

class _MockPantryLocalDs extends Mock implements PantryLocalDs {}

class _MockPurchaseLocalDs extends Mock implements PurchaseLocalDs {}

class _MockSyncRecorder extends Mock implements SyncRecorder {}

class _FakeProductModel extends Fake implements ProductModel {}

class _FakePantryItemModel extends Fake implements PantryItemModel {}

class _FakePurchaseModel extends Fake implements PurchaseModel {}

class _FakePurchaseItemModel extends Fake implements PurchaseItemModel {}

const _product = Product(
  id: 'prod-1',
  name: 'Arroz',
  categoryId: 'cat-1',
  unit: 'kg',
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeProductModel());
    registerFallbackValue(_FakePantryItemModel());
    registerFallbackValue(_FakePurchaseModel());
    registerFallbackValue(_FakePurchaseItemModel());
  });

  late _MockSyncRecorder sync;

  setUp(() {
    sync = _MockSyncRecorder();
    when(() => sync.recordUpsert(any(), any())).thenAnswer((_) async {});
    when(() => sync.recordDelete(any(), any())).thenAnswer((_) async {});
    when(() => sync.recordUpsertAll(any(), any())).thenAnswer((_) async {});
  });

  group('ProductRepositoryImpl', () {
    late _MockProductLocalDs dataSource;
    late ProductRepositoryImpl repository;

    setUp(() {
      dataSource = _MockProductLocalDs();
      repository = ProductRepositoryImpl(dataSource, sync);
      when(() => dataSource.insert(any())).thenAnswer((_) async {});
      when(() => dataSource.update(any())).thenAnswer((_) async {});
      when(() => dataSource.delete(any())).thenAnswer((_) async {});
    });

    test('should queue an upsert after creating', () async {
      await repository.create(_product);

      verify(
        () => sync.recordUpsert(SyncEntities.products, 'prod-1'),
      ).called(1);
    });

    test('should queue an upsert after updating', () async {
      await repository.update(_product);

      verify(
        () => sync.recordUpsert(SyncEntities.products, 'prod-1'),
      ).called(1);
    });

    test('should queue a delete after removing', () async {
      await repository.delete('prod-1');

      verify(
        () => sync.recordDelete(SyncEntities.products, 'prod-1'),
      ).called(1);
    });
  });

  group('PantryRepositoryImpl', () {
    late _MockPantryLocalDs dataSource;
    late PantryRepositoryImpl repository;

    setUp(() {
      dataSource = _MockPantryLocalDs();
      repository = PantryRepositoryImpl(dataSource, sync);
      when(() => dataSource.insert(any())).thenAnswer((_) async {});
      when(
        () => dataSource.updateQuantity(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => dataSource.updateIdealQuantity(any(), any()),
      ).thenAnswer((_) async {});
      when(() => dataSource.delete(any())).thenAnswer((_) async {});
    });

    test('should queue an upsert when the quantity changes', () async {
      await repository.updateQuantity('pantry-1', 3);

      verify(
        () => sync.recordUpsert(SyncEntities.pantryItems, 'pantry-1'),
      ).called(1);
    });

    test('should queue an upsert when the ideal quantity changes', () async {
      await repository.updateIdealQuantity('pantry-1', 5);

      verify(
        () => sync.recordUpsert(SyncEntities.pantryItems, 'pantry-1'),
      ).called(1);
    });

    test('should queue an upsert when an item is added', () async {
      await repository.add(
        const PantryItem(
          id: 'pantry-1',
          productId: 'prod-1',
          currentQuantity: 1,
          idealQuantity: 2,
        ),
      );

      verify(
        () => sync.recordUpsert(SyncEntities.pantryItems, 'pantry-1'),
      ).called(1);
    });

    test('should queue a delete when an item is removed', () async {
      await repository.remove('pantry-1');

      verify(
        () => sync.recordDelete(SyncEntities.pantryItems, 'pantry-1'),
      ).called(1);
    });
  });

  group('PurchaseRepositoryImpl', () {
    late _MockPurchaseLocalDs dataSource;
    late PurchaseRepositoryImpl repository;

    setUp(() {
      dataSource = _MockPurchaseLocalDs();
      repository = PurchaseRepositoryImpl(dataSource, sync);
      when(() => dataSource.insert(any())).thenAnswer((_) async {});
      when(() => dataSource.insertItem(any())).thenAnswer((_) async {});
      when(() => dataSource.delete(any())).thenAnswer((_) async {});
      when(
        () => dataSource.updateStatus(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => dataSource.getItemsByPurchaseId(any()),
      ).thenAnswer((_) async => const []);
    });

    test('should queue the purchase and each of its items', () async {
      await repository.create(
        Purchase(
          id: 'purchase-1',
          date: DateTime(2026, 7, 27),
          type: PurchaseType.main,
          status: PurchaseStatus.completed,
          items: const [
            PurchaseItem(
              id: 'item-1',
              purchaseId: 'purchase-1',
              productId: 'prod-1',
              quantity: 2,
            ),
          ],
        ),
      );

      verify(
        () => sync.recordUpsert(SyncEntities.purchases, 'purchase-1'),
      ).called(1);
      verify(
        () => sync.recordUpsert(SyncEntities.purchaseItems, 'item-1'),
      ).called(1);
    });

    // O sqflite apaga os itens junto com a compra; sem uma operação por item a
    // exclusão nunca chegaria ao Appwrite.
    test(
      'should queue a delete for every item of a deleted purchase',
      () async {
        when(() => dataSource.getItemsByPurchaseId('purchase-1')).thenAnswer(
          (_) async => const [
            PurchaseItemModel(
              id: 'item-1',
              purchaseId: 'purchase-1',
              productId: 'prod-1',
              quantity: 1,
            ),
            PurchaseItemModel(
              id: 'item-2',
              purchaseId: 'purchase-1',
              productId: 'prod-2',
              quantity: 1,
            ),
          ],
        );

        await repository.delete('purchase-1');

        verify(
          () => sync.recordDelete(SyncEntities.purchaseItems, 'item-1'),
        ).called(1);
        verify(
          () => sync.recordDelete(SyncEntities.purchaseItems, 'item-2'),
        ).called(1);
        verify(
          () => sync.recordDelete(SyncEntities.purchases, 'purchase-1'),
        ).called(1);
      },
    );

    test('should queue an upsert when the status changes', () async {
      await repository.updateStatus('purchase-1', PurchaseStatus.completed);

      verify(
        () => sync.recordUpsert(SyncEntities.purchases, 'purchase-1'),
      ).called(1);
    });
  });

  group('PurchaseItemRepositoryImpl', () {
    late _MockPurchaseLocalDs dataSource;
    late PurchaseItemRepositoryImpl repository;

    setUp(() {
      dataSource = _MockPurchaseLocalDs();
      repository = PurchaseItemRepositoryImpl(dataSource, sync);
      when(() => dataSource.insertItem(any())).thenAnswer((_) async {});
      when(() => dataSource.updateItem(any())).thenAnswer((_) async {});
      when(() => dataSource.deleteItem(any())).thenAnswer((_) async {});
    });

    test('should queue an upsert when an item is added', () async {
      await repository.addItem(
        const PurchaseItem(
          id: 'item-1',
          purchaseId: 'purchase-1',
          productId: 'prod-1',
          quantity: 1,
        ),
      );

      verify(
        () => sync.recordUpsert(SyncEntities.purchaseItems, 'item-1'),
      ).called(1);
    });

    test('should queue a delete when an item is removed', () async {
      await repository.removeItem('item-1');

      verify(
        () => sync.recordDelete(SyncEntities.purchaseItems, 'item-1'),
      ).called(1);
    });
  });
}
