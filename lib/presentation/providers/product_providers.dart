import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../core/di/providers.dart';

const _uuid = Uuid();

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

final productSearchQueryProvider = StateProvider<String>((_) => '');

final selectedCategoryFilterProvider = StateProvider<String?>((_) => null);

final filteredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  final query = ref.watch(productSearchQueryProvider);
  final categoryId = ref.watch(selectedCategoryFilterProvider);

  var result = products;

  if (categoryId != null) {
    result = result.where((p) => p.categoryId == categoryId).toList();
  }

  if (query.isNotEmpty) {
    final lower = query.toLowerCase();
    result = result.where((p) => p.name.toLowerCase().contains(lower)).toList();
  }

  return result;
});

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  GetAllProducts get _getAll => ref.watch(getAllProductsProvider);
  CreateProduct get _create => ref.watch(createProductProvider);
  UpdateProduct get _update => ref.watch(updateProductProvider);
  DeleteProduct get _delete => ref.watch(deleteProductProvider);

  @override
  Future<List<Product>> build() => _getAll();

  Future<void> add(String name, String categoryId, String unit) async {
    final product = Product(
      id: _uuid.v4(),
      name: name,
      categoryId: categoryId,
      unit: unit,
    );
    await _create(product);
    ref.invalidateSelf();
  }

  Future<void> edit(Product product) async {
    await _update(product);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await _delete(id);
    ref.invalidateSelf();
  }
}
