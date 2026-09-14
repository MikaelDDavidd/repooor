import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/purchase_item.dart';
import '../providers/category_providers.dart';
import '../providers/nfce_providers.dart';
import '../providers/product_providers.dart';
import '../providers/purchase_providers.dart';
import '../shared/utils/category_grouping.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_loading_state.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/category_section_header.dart';
import '../shared/widgets/app_icon_button.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/item_pick_dialog.dart';
import '../shared/widgets/slide_confirm_dialog.dart';
import '../shared/widgets/pick_check_button.dart';
import 'purchase_add_item_page.dart';
import 'widgets/purchase_item_price_label.dart';
import 'widgets/purchase_plan_summary.dart';
import 'widgets/purchase_total_chip.dart';

class PurchaseDetailPage extends ConsumerWidget {
  const PurchaseDetailPage({super.key, required this.purchaseId});

  final String purchaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(purchaseItemsProvider(purchaseId));
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);
    final purchase = ref.watch(purchaseByIdProvider(purchaseId)).valueOrNull;
    final isPlanned = purchase?.isPlanned ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(isPlanned ? 'Compra planejada' : 'Itens da Compra'),
        actions: [
          if (isPlanned)
            TextButton(
              onPressed: () => _reconcile(context, ref),
              child: const Text('Conciliar nota'),
            ),
          TextButton(
            onPressed: () => _completePurchase(context, ref, isPlanned),
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
        data: (purchaseItems) => _buildItemsList(
          context,
          ref,
          purchaseItems,
          products,
          categories,
          isPlanned,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Navigator.of(context, rootNavigator: true).push(
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
    List<PurchaseItem> purchaseItems,
    AsyncValue products,
    AsyncValue categories,
    bool isPlanned,
  ) {
    if (purchaseItems.isEmpty) {
      return const AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Lista vazia',
        subtitle: 'Toque no + para adicionar itens',
      );
    }

    final productList = (products.valueOrNull as List<Product>?) ?? [];
    final productMap = {for (final p in productList) p.id: p};
    final categoryList = (categories.valueOrNull as List<Category>?) ?? [];

    final groups = groupByCategory(
      items: purchaseItems,
      categoryIdOf: (item) => productMap[item.productId]?.categoryId ?? '',
      categories: categoryList,
    );

    for (final g in groups) {
      g.items.sort((a, b) {
        final nameA = productMap[a.productId]?.name ?? '';
        final nameB = productMap[b.productId]?.name ?? '';
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      });
    }

    final priced = purchaseItems.where((i) => i.unitPrice != null);
    final totalPrice = priced.isEmpty
        ? null
        : priced.fold<double>(0, (sum, i) => sum + i.totalPrice!);
    final isPartial = priced.length != purchaseItems.length;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PurchasePlanSummary(items: purchaseItems),
              _PurchaseSummaryHeader(
                totalItems: purchaseItems.length,
                totalPrice: totalPrice,
                isPartial: isPartial,
              ),
            ],
          );
        }
        final group = groups[i - 1];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CategorySectionHeader(category: group.category),
            const SizedBox(height: 8),
            ...group.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildItemTile(
                  context,
                  ref,
                  item,
                  productMap,
                  group.category,
                  isPlanned,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemTile(
    BuildContext context,
    WidgetRef ref,
    PurchaseItem item,
    Map<String, Product> productMap,
    Category? category,
    bool isPlanned,
  ) {
    final product = productMap[item.productId];
    final catColor = category != null
        ? Color(category.color)
        : AppColors.textSecondary;
    final catIcon = category != null
        ? IconData(category.icon, fontFamily: 'MaterialIcons')
        : Icons.category;
    final showCheck = isPlanned;
    final picked = showCheck && item.picked;

    return Card(
      color: picked ? AppColors.primary : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showCheck
            ? _togglePicked(context, ref, item, product)
            : _editItem(context, ref, item, product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (showCheck)
                PickCheckButton(
                  picked: item.picked,
                  onPressed: () => _togglePicked(context, ref, item, product),
                  fallbackIcon: catIcon,
                  fallbackColor: catColor,
                )
              else
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
                    Text(
                      product?.name ?? 'Produto',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary.withValues(
                          alpha: picked ? 0.75 : 1,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    PurchaseItemPriceLabel(
                      quantity: item.quantity,
                      unit: product?.unit ?? '',
                      unitPrice: item.unitPrice,
                      onFilledBackground: picked,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (picked)
                AppIconButton(
                  icon: Icons.close,
                  color: AppColors.textPrimary.withValues(alpha: 0.75),
                  tooltip: 'Desmarcar',
                  onPressed: () => _togglePicked(context, ref, item, product),
                )
              else
                AppIconButton(
                  icon: Icons.delete_outline,
                  color: AppColors.textSecondary,
                  tooltip: 'Tirar da compra',
                  onPressed: () => ref
                      .read(purchaseItemsProvider(purchaseId).notifier)
                      .removeItem(item.id),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editItem(
    BuildContext context,
    WidgetRef ref,
    PurchaseItem item,
    Product? product,
  ) async {
    final result = await ItemPickDialog.show(
      context,
      title: 'Ajustar item',
      productName: product?.name ?? 'Produto',
      unit: product?.unit ?? '',
      initialQuantity: item.quantity,
      initialUnitPrice: item.unitPrice,
      confirmLabel: 'Salvar',
    );
    if (result == null) return;
    await ref
        .read(purchaseItemsProvider(purchaseId).notifier)
        .updateItem(
          item.id,
          result.quantity,
          unitPrice: result.unitPrice,
          clearUnitPrice: result.unitPrice == null,
        );
  }

  Future<void> _togglePicked(
    BuildContext context,
    WidgetRef ref,
    PurchaseItem item,
    Product? product,
  ) async {
    final notifier = ref.read(purchaseItemsProvider(purchaseId).notifier);
    final name = product?.name ?? 'Item';

    if (item.picked) {
      final confirmed = await SlideConfirmDialog.show(
        context,
        title: 'Tirar do carrinho?',
        message:
            '"$name" volta para a lista de itens a pegar. Arraste para confirmar.',
        slideLabel: 'Arraste para desmarcar',
      );
      if (confirmed == true) await notifier.unpickItem(item.id);
      return;
    }

    final result = await ItemPickDialog.show(
      context,
      productName: name,
      unit: product?.unit ?? '',
      initialQuantity: item.quantity,
      initialUnitPrice: item.unitPrice,
      confirmLabel: 'Salvar',
    );
    if (result == null) return;
    await notifier.pickItem(
      item.id,
      quantity: result.quantity,
      unitPrice: result.unitPrice,
    );
  }

  Future<void> _reconcile(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Conciliar com a nota',
      content:
          'Escaneie o QR Code do cupom fiscal. Os valores reais entram no lugar dos projetados, e o que você projetou fica guardado para comparação.',
      confirmLabel: 'Escanear',
    );
    if (confirmed != true || !context.mounted) return;
    final router = GoRouter.of(context);
    ref.read(nfceImportProvider.notifier).startReconciliation(purchaseId);
    Navigator.of(context).pop();
    router.push('/nfce/scan');
  }

  Future<void> _completePurchase(
    BuildContext context,
    WidgetRef ref,
    bool isPlanned,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Finalizar compra',
      content: isPlanned
          ? 'As quantidades compradas serão adicionadas à despensa e a compra deixa de ser um plano. Continuar?'
          : 'As quantidades serão adicionadas à despensa. Continuar?',
      confirmLabel: 'Finalizar',
    );
    if (confirmed == true) {
      await ref.read(purchasesProvider.notifier).completePurchase(purchaseId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra finalizada! Despensa atualizada.'),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}

class _PurchaseSummaryHeader extends StatelessWidget {
  const _PurchaseSummaryHeader({
    required this.totalItems,
    required this.totalPrice,
    required this.isPartial,
  });

  final int totalItems;
  final double? totalPrice;
  final bool isPartial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$totalItems ${totalItems == 1 ? 'item' : 'itens'}',
            style: AppTextStyles.bodySecondary,
          ),
          PurchaseTotalChip(total: totalPrice, partial: isPartial),
        ],
      ),
    );
  }
}
