import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../providers/category_providers.dart';
import '../providers/product_providers.dart';
import '../shared/utils/category_grouping.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/app_loading_state.dart';
import '../shared/widgets/category_section_header.dart';
import '../shared/widgets/confirm_dialog.dart';
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
          child: _buildSearchAndFilter(
            context,
            ref,
            categories,
            selectedCategory,
          ),
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
          final cats = categories.valueOrNull ?? [];
          if (selectedCategory != null) {
            return _buildFlatList(context, ref, items, cats);
          }
          return _buildGroupedList(context, ref, items, cats);
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProductFormPage())),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFlatList(
    BuildContext context,
    WidgetRef ref,
    List<Product> items,
    List<Category> cats,
  ) {
    final sorted = List<Product>.from(items)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildProductCard(context, ref, sorted[index], cats),
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    WidgetRef ref,
    List<Product> items,
    List<Category> cats,
  ) {
    final groups = groupByCategory<Product>(
      items: items,
      categoryIdOf: (p) => p.categoryId,
      categories: cats,
    );
    for (final g in groups) {
      g.items.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final group = groups[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CategorySectionHeader(category: group.category),
            const SizedBox(height: 8),
            ...group.items.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildProductCard(context, ref, product, cats),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    WidgetRef ref,
    Product product,
    List<Category> cats,
  ) {
    return ProductCard(
      product: product,
      categories: cats,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
      ),
      onEdit: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
      ),
      onDelete: () async {
        final confirmed = await ConfirmDialog.show(
          context,
          title: 'Deletar produto',
          content: 'Tem certeza que deseja deletar "${product.name}"?',
          confirmLabel: 'Deletar',
          isDestructive: true,
        );
        if (confirmed == true) {
          ref.read(productsProvider.notifier).remove(product.id);
        }
      },
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
            onChanged: (v) =>
                ref.read(productSearchQueryProvider.notifier).state = v,
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
                          ? AppColors.primaryStrong
                          : AppColors.textSecondary,
                      fontWeight: selectedCategory == null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    onSelected: (_) =>
                        ref
                                .read(selectedCategoryFilterProvider.notifier)
                                .state =
                            null,
                  ),
                ),
                ...cats.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: selectedCategory == cat.id,
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        color: selectedCategory == cat.id
                            ? AppColors.primaryStrong
                            : AppColors.textSecondary,
                        fontWeight: selectedCategory == cat.id
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      onSelected: (_) =>
                          ref
                              .read(selectedCategoryFilterProvider.notifier)
                              .state = selectedCategory == cat.id
                          ? null
                          : cat.id,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
