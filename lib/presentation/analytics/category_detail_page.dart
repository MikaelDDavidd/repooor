import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../providers/analytics_providers.dart';
import '../providers/category_providers.dart';
import '../providers/product_providers.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/app_loading_state.dart';

class CategoryDetailPage extends ConsumerWidget {
  const CategoryDetailPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);
    final consumption = ref.watch(consumptionByCategoryProvider);

    final categoryList = categories.valueOrNull?.where((c) => c.id == categoryId);
    final category = (categoryList != null && categoryList.isNotEmpty) ? categoryList.first : null;

    return Scaffold(
      appBar: AppBar(title: Text(category?.name ?? 'Categoria')),
      body: _buildBody(category, products, consumption, ref),
    );
  }

  Widget _buildBody(
    Category? category,
    AsyncValue<List<Product>> products,
    AsyncValue<Map<String, double>> consumption,
    WidgetRef ref,
  ) {
    if (category == null) {
      return const AppEmptyState(
        icon: Icons.category_outlined,
        title: 'Categoria nao encontrada',
      );
    }

    return products.when(
      loading: () => const AppLoadingState(),
      error: (_, _) => AppErrorState(
        message: 'Erro ao carregar produtos',
        onRetry: () => ref.invalidate(productsProvider),
      ),
      data: (allProducts) {
        final categoryProducts = allProducts
            .where((p) => p.categoryId == categoryId)
            .toList();
        return _buildContent(category, categoryProducts, consumption, ref);
      },
    );
  }

  Widget _buildContent(
    Category category,
    List<Product> products,
    AsyncValue<Map<String, double>> consumption,
    WidgetRef ref,
  ) {
    final color = Color(category.color);
    final icon = IconData(category.icon, fontFamily: 'MaterialIcons');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(icon, color, category.name),
        const SizedBox(height: 24),
        consumption.when(
          loading: () => const SizedBox(
            height: 100,
            child: AppLoadingState(),
          ),
          error: (_, _) => AppErrorState(
            message: 'Erro ao carregar consumo',
            onRetry: () => ref.invalidate(consumptionByCategoryProvider),
          ),
          data: (data) => _buildProductList(products, data, ref),
        ),
      ],
    );
  }

  Widget _buildHeader(IconData icon, Color color, String name) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Text(name, style: AppTextStyles.heading1),
      ],
    );
  }

  Widget _buildProductList(
    List<Product> products,
    Map<String, double> consumptionData,
    WidgetRef ref,
  ) {
    if (products.isEmpty) {
      return const AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Nenhum produto',
        subtitle: 'Nenhum produto nesta categoria',
      );
    }

    final topProducts = ref.watch(topProductsProvider);
    final productTotals = <String, double>{};

    if (topProducts.hasValue) {
      for (final tp in topProducts.value!) {
        productTotals[tp.productId] = tp.totalQuantity;
      }
    }

    final sorted = List<Product>.from(products)
      ..sort((a, b) => (productTotals[b.id] ?? 0)
          .compareTo(productTotals[a.id] ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Produtos', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        ...sorted.map((product) {
          final total = productTotals[product.id] ?? 0;
          return Card(
            child: ListTile(
              title: Text(product.name, style: AppTextStyles.body),
              subtitle: Text(product.unit, style: AppTextStyles.caption),
              trailing: Text(
                total > 0 ? total.toStringAsFixed(0) : '-',
                style: AppTextStyles.body.copyWith(
                  color: total > 0 ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
