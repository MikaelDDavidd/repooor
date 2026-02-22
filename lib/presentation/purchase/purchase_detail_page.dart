import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/pantry_item.dart';
import '../providers/category_providers.dart';
import '../providers/pantry_providers.dart';
import '../providers/product_providers.dart';
import '../providers/purchase_providers.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_loading_state.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/confirm_dialog.dart';
import 'purchase_add_item_page.dart';

class PurchaseDetailPage extends ConsumerWidget {
  const PurchaseDetailPage({super.key, required this.purchaseId});

  final String purchaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(purchaseItemsProvider(purchaseId));
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);
    final pantryItems = ref.watch(pantryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itens da Compra'),
        actions: [
          TextButton(
            onPressed: () => _suggestItems(context, ref, pantryItems),
            child: const Text('Sugerir'),
          ),
          TextButton(
            onPressed: () => _completePurchase(context, ref),
            child: const Text('Finalizar'),
          ),
        ],
      ),
      body: items.when(
        loading: () => const AppLoadingState(),
        error: (e, _) => AppErrorState(
          message: 'Erro ao carregar itens',
          onRetry: () => ref.invalidate(purchaseItemsProvider(purchaseId)),
        ),
        data: (purchaseItems) => _buildItemsList(context, ref, purchaseItems, products, categories),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PurchaseAddItemPage(purchaseId: purchaseId),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    WidgetRef ref,
    List purchaseItems,
    AsyncValue products,
    AsyncValue categories,
  ) {
    if (purchaseItems.isEmpty) {
      return const AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Lista vazia',
        subtitle: 'Adicione itens ou toque em "Sugerir"',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: purchaseItems.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = purchaseItems[index];
        final productMatches = products.valueOrNull?.where((p) => p.id == item.productId);
        final product = (productMatches != null && productMatches.isNotEmpty) ? productMatches.first : null;
        final categoryMatches = categories.valueOrNull?.where((c) => c.id == product?.categoryId);
        final category = (categoryMatches != null && categoryMatches.isNotEmpty) ? categoryMatches.first : null;
        final catColor = category != null ? Color(category.color) : AppColors.textSecondary;
        final catIcon = category != null
            ? IconData(category.icon, fontFamily: 'MaterialIcons')
            : Icons.category;

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _editQuantity(context, ref, item.id, item.quantity),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(catIcon, color: catColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product?.name ?? 'Produto', style: AppTextStyles.body),
                        const SizedBox(height: 2),
                        Text(
                          '${item.quantity.toStringAsFixed(0)} ${product?.unit ?? ''}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => ref
                        .read(purchaseItemsProvider(purchaseId).notifier)
                        .removeItem(item.id),
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.error,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editQuantity(
    BuildContext context,
    WidgetRef ref,
    String itemId,
    double currentQty,
  ) async {
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => _EditQuantityDialog(initialValue: currentQty),
    );
    if (result != null && result > 0) {
      ref.read(purchaseItemsProvider(purchaseId).notifier).updateItem(itemId, result);
    }
  }

  Future<void> _suggestItems(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<PantryItem>> pantryItems,
  ) async {
    final items = pantryItems.valueOrNull ?? [];
    final lowItems = items.where((i) => i.deficit > 0).toList();
    if (lowItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os itens estão no nível ideal!')),
      );
      return;
    }
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Sugerir itens',
      content: '${lowItems.length} itens estão abaixo do ideal. Adicionar à compra?',
      confirmLabel: 'Adicionar',
    );
    if (confirmed == true) {
      final notifier = ref.read(purchaseItemsProvider(purchaseId).notifier);
      for (final pantryItem in lowItems) {
        await notifier.addItem(pantryItem.productId, pantryItem.deficit);
      }
    }
  }

  Future<void> _completePurchase(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Finalizar compra',
      content: 'As quantidades serão adicionadas à despensa. Continuar?',
      confirmLabel: 'Finalizar',
    );
    if (confirmed == true) {
      await ref.read(purchasesProvider.notifier).completePurchase(purchaseId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra finalizada! Despensa atualizada.')),
        );
        Navigator.of(context).pop();
      }
    }
  }
}

class _EditQuantityDialog extends StatefulWidget {
  const _EditQuantityDialog({required this.initialValue});

  final double initialValue;

  @override
  State<_EditQuantityDialog> createState() => _EditQuantityDialogState();
}

class _EditQuantityDialogState extends State<_EditQuantityDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quantidade'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final v = double.tryParse(_controller.text);
            Navigator.of(context).pop(v);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
