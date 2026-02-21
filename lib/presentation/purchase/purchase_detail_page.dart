import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/pantry_item.dart';
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
        data: (purchaseItems) => _buildItemsList(context, ref, purchaseItems, products),
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
        final product = products.valueOrNull
            ?.where((p) => p.id == item.productId)
            .firstOrNull;
        return Card(
          child: ListTile(
            title: Text(product?.name ?? 'Produto', style: AppTextStyles.body),
            subtitle: Text('${item.quantity.toStringAsFixed(0)} ${product?.unit ?? ''}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.textSecondary,
                  onPressed: () => _editQuantity(context, ref, item.id, item.quantity),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.error,
                  onPressed: () => ref
                      .read(purchaseItemsProvider(purchaseId).notifier)
                      .removeItem(item.id),
                ),
              ],
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
    final controller = TextEditingController(text: currentQty.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quantidade'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              Navigator.of(ctx).pop(v);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
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
