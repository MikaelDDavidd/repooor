import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/category_local_ds.dart';
import '../../data/datasources/product_local_ds.dart';
import '../../data/datasources/pantry_local_ds.dart';
import '../../data/datasources/purchase_local_ds.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/pantry_repository_impl.dart';
import '../../data/repositories/purchase_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/pantry_repository.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../domain/usecases/get_all_categories.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/seed_default_categories.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_pantry_items.dart';
import '../../domain/usecases/add_to_pantry.dart';
import '../../domain/usecases/update_pantry_quantity.dart';
import '../../domain/usecases/update_ideal_quantity.dart';
import '../../domain/usecases/remove_from_pantry.dart';
import '../../domain/usecases/get_low_stock_items.dart';
import '../../domain/usecases/get_all_purchases.dart';
import '../../domain/usecases/get_purchase_by_id.dart';
import '../../domain/usecases/create_purchase.dart';
import '../../domain/usecases/delete_purchase.dart';
import '../../domain/usecases/add_purchase_item.dart';
import '../../domain/usecases/update_purchase_item.dart';
import '../../domain/usecases/remove_purchase_item.dart';
import '../../domain/usecases/complete_purchase.dart';

final categoryLocalDsProvider = Provider<CategoryLocalDs>((_) => CategoryLocalDs());
final productLocalDsProvider = Provider<ProductLocalDs>((_) => ProductLocalDs());
final pantryLocalDsProvider = Provider<PantryLocalDs>((_) => PantryLocalDs());
final purchaseLocalDsProvider = Provider<PurchaseLocalDs>((_) => PurchaseLocalDs());

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.watch(categoryLocalDsProvider)),
);
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(ref.watch(productLocalDsProvider)),
);
final pantryRepositoryProvider = Provider<PantryRepository>(
  (ref) => PantryRepositoryImpl(ref.watch(pantryLocalDsProvider)),
);
final purchaseRepositoryProvider = Provider<PurchaseRepository>(
  (ref) => PurchaseRepositoryImpl(ref.watch(purchaseLocalDsProvider)),
);

final getAllCategoriesProvider = Provider((ref) => GetAllCategories(ref.watch(categoryRepositoryProvider)));
final createCategoryProvider = Provider((ref) => CreateCategory(ref.watch(categoryRepositoryProvider)));
final updateCategoryProvider = Provider((ref) => UpdateCategory(ref.watch(categoryRepositoryProvider)));
final deleteCategoryProvider = Provider((ref) => DeleteCategory(ref.watch(categoryRepositoryProvider)));
final seedDefaultCategoriesProvider = Provider((ref) => SeedDefaultCategories(ref.watch(categoryRepositoryProvider)));

final getAllProductsProvider = Provider((ref) => GetAllProducts(ref.watch(productRepositoryProvider)));
final createProductProvider = Provider((ref) => CreateProduct(ref.watch(productRepositoryProvider)));
final updateProductProvider = Provider((ref) => UpdateProduct(ref.watch(productRepositoryProvider)));
final deleteProductProvider = Provider((ref) => DeleteProduct(ref.watch(productRepositoryProvider)));

final getPantryItemsProvider = Provider((ref) => GetPantryItems(ref.watch(pantryRepositoryProvider)));
final addToPantryProvider = Provider((ref) => AddToPantry(ref.watch(pantryRepositoryProvider)));
final updatePantryQuantityProvider = Provider((ref) => UpdatePantryQuantity(ref.watch(pantryRepositoryProvider)));
final updateIdealQuantityProvider = Provider((ref) => UpdateIdealQuantity(ref.watch(pantryRepositoryProvider)));
final removeFromPantryProvider = Provider((ref) => RemoveFromPantry(ref.watch(pantryRepositoryProvider)));
final getLowStockItemsProvider = Provider((ref) => GetLowStockItems(ref.watch(pantryRepositoryProvider)));

final getAllPurchasesProvider = Provider((ref) => GetAllPurchases(ref.watch(purchaseRepositoryProvider)));
final getPurchaseByIdProvider = Provider((ref) => GetPurchaseById(ref.watch(purchaseRepositoryProvider)));
final createPurchaseProvider = Provider((ref) => CreatePurchase(ref.watch(purchaseRepositoryProvider)));
final deletePurchaseProvider = Provider((ref) => DeletePurchase(ref.watch(purchaseRepositoryProvider)));
final addPurchaseItemProvider = Provider((ref) => AddPurchaseItem(ref.watch(purchaseRepositoryProvider)));
final updatePurchaseItemProvider = Provider((ref) => UpdatePurchaseItem(ref.watch(purchaseRepositoryProvider)));
final removePurchaseItemProvider = Provider((ref) => RemovePurchaseItem(ref.watch(purchaseRepositoryProvider)));
final completePurchaseProvider = Provider((ref) => CompletePurchase(
  ref.watch(purchaseRepositoryProvider),
  ref.watch(pantryRepositoryProvider),
));
