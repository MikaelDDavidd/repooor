import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/category_local_ds.dart';
import '../../data/datasources/product_local_ds.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_all_categories.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/seed_default_categories.dart';

final categoryLocalDsProvider = Provider<CategoryLocalDs>(
  (_) => CategoryLocalDs(),
);

final productLocalDsProvider = Provider<ProductLocalDs>(
  (_) => ProductLocalDs(),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.watch(categoryLocalDsProvider)),
);

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(ref.watch(productLocalDsProvider)),
);

final getAllCategoriesProvider = Provider<GetAllCategories>(
  (ref) => GetAllCategories(ref.watch(categoryRepositoryProvider)),
);

final createCategoryProvider = Provider<CreateCategory>(
  (ref) => CreateCategory(ref.watch(categoryRepositoryProvider)),
);

final updateCategoryProvider = Provider<UpdateCategory>(
  (ref) => UpdateCategory(ref.watch(categoryRepositoryProvider)),
);

final deleteCategoryProvider = Provider<DeleteCategory>(
  (ref) => DeleteCategory(ref.watch(categoryRepositoryProvider)),
);

final seedDefaultCategoriesProvider = Provider<SeedDefaultCategories>(
  (ref) => SeedDefaultCategories(ref.watch(categoryRepositoryProvider)),
);

final getAllProductsProvider = Provider<GetAllProducts>(
  (ref) => GetAllProducts(ref.watch(productRepositoryProvider)),
);

final createProductProvider = Provider<CreateProduct>(
  (ref) => CreateProduct(ref.watch(productRepositoryProvider)),
);

final updateProductProvider = Provider<UpdateProduct>(
  (ref) => UpdateProduct(ref.watch(productRepositoryProvider)),
);

final deleteProductProvider = Provider<DeleteProduct>(
  (ref) => DeleteProduct(ref.watch(productRepositoryProvider)),
);
