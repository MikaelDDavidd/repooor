import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';
import '../providers/product_providers.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/app_loading_state.dart';
import 'product_form_page.dart';
import 'widgets/product_card.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(filteredProductsProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: _buildSearchAndFilter(context, ref, categories, selectedCategory),
        ),
      ),
      body: products.when(
        loading: () => const AppLoadingState(),
        error: (e, _) => AppErrorState(
          message: 'Erro ao carregar produtos',
          onRetry: () => ref.invalidate(productsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Nenhum produto',
              subtitle: 'Adicione seu primeiro produto tocando no botão +',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = items[index];
              return ProductCard(
                product: product,
                categories: categories.valueOrNull ?? [],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductFormPage(product: product),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProductFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Category>> categories,
    String? selectedCategory,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (v) => ref.read(productSearchQueryProvider.notifier).state = v,
            decoration: const InputDecoration(
              hintText: 'Buscar produto...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: categories.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (cats) => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: selectedCategory == null,
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(
                      color: selectedCategory == null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: selectedCategory == null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    onSelected: (_) =>
                        ref.read(selectedCategoryFilterProvider.notifier).state = null,
                  ),
                ),
                ...cats.map((cat) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat.name),
                    selected: selectedCategory == cat.id,
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(
                      color: selectedCategory == cat.id
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: selectedCategory == cat.id
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    onSelected: (_) =>
                        ref.read(selectedCategoryFilterProvider.notifier).state =
                            selectedCategory == cat.id ? null : cat.id,
                  ),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
