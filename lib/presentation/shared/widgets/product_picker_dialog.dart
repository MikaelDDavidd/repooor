import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../providers/product_providers.dart';
import '../../providers/category_providers.dart';
import '../../products/product_form_page.dart';
import '../utils/category_grouping.dart';
import 'category_section_header.dart';
import 'confirm_dialog.dart';

class ProductPickerDialog extends ConsumerStatefulWidget {
  const ProductPickerDialog({super.key, this.excludeIds = const {}});

  final Set<String> excludeIds;

  static Future<Product?> show(
    BuildContext context, {
    Set<String> excludeIds = const {},
  }) {
    return Navigator.of(context).push<Product>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ProductPickerDialog(excludeIds: excludeIds),
      ),
    );
  }

  @override
  ConsumerState<ProductPickerDialog> createState() =>
      _ProductPickerDialogState();
}

class _ProductPickerDialogState extends ConsumerState<ProductPickerDialog> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _query = value.toLowerCase());
    });
  }

  List<Product> _filterProducts(List<Product> products) {
    final available = products
        .where((p) => !widget.excludeIds.contains(p.id))
        .toList();
    if (_query.isEmpty) return available;
    return available
        .where((p) => p.name.toLowerCase().contains(_query))
        .toList();
  }

  Future<void> _openCreateProduct() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProductFormPage()));
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        title: const Text('Selecionar Produto'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: _openCreateProduct,
        child: const Icon(Icons.add),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Erro ao carregar produtos')),
        data: (allProducts) {
          final cats = categoriesAsync.valueOrNull ?? [];
          final categoryMap = {for (final c in cats) c.id: c};
          final filtered = _filterProducts(allProducts);

          final groups = groupByCategory<Product>(
            items: filtered,
            categoryIdOf: (p) => p.categoryId,
            categories: cats,
          );
          for (final g in groups) {
            g.items.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Buscar produto...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, i) {
                          final group = groups[i];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CategorySectionHeader(category: group.category),
                              ...group.items.map(
                                (p) => _ProductPickerTile(
                                  product: p,
                                  category: categoryMap[p.categoryId],
                                  onTap: () => Navigator.of(context).pop(p),
                                  onEdit: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductFormPage(product: p),
                                    ),
                                  ),
                                  onDelete: () async {
                                    final confirmed = await ConfirmDialog.show(
                                      context,
                                      title: 'Apagar produto',
                                      content:
                                          'Tem certeza que deseja apagar "${p.name}"?',
                                      confirmLabel: 'Apagar',
                                      isDestructive: true,
                                    );
                                    if (confirmed == true) {
                                      await ref
                                          .read(productsProvider.notifier)
                                          .remove(p.id);
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            _query.isEmpty
                ? 'Nenhum produto disponivel'
                : 'Nenhum produto encontrado',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProductPickerTile extends StatelessWidget {
  const _ProductPickerTile({
    required this.product,
    required this.category,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Product product;
  final Category? category;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final hasDismiss = onEdit != null || onDelete != null;

    final card = SizedBox(
      height: 72,
      child: Card(
        margin: hasDismiss
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: category != null
                        ? Color(category!.color).withValues(alpha: 0.15)
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category != null
                        ? IconData(category!.icon, fontFamily: 'MaterialIcons')
                        : Icons.category,
                    color: category != null
                        ? Color(category!.color)
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: AppTextStyles.body),
                      const SizedBox(height: 2),
                      Text(product.unit, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!hasDismiss) return card;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Dismissible(
          key: ValueKey(product.id),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24),
            color: AppColors.primaryStrong,
            child: const Icon(Icons.edit, color: AppColors.onPrimary),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: AppColors.error,
            child: const Icon(Icons.delete, color: AppColors.onPrimary),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              onEdit?.call();
              return false;
            }
            onDelete?.call();
            return false;
          },
          child: card,
        ),
      ),
    );
  }
}
