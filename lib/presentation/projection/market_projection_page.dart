import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/projection/market_projection.dart';
import '../../domain/entities/projection/projected_item.dart';
import '../../domain/entities/purchase.dart';
import '../providers/category_providers.dart';
import '../providers/projection_providers.dart';
import '../purchase/purchase_detail_page.dart';
import '../shared/utils/category_grouping.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/app_loading_state.dart';
import '../shared/widgets/category_section_header.dart';
import '../shared/widgets/item_pick_dialog.dart';
import '../shared/widgets/slide_confirm_dialog.dart';
import 'widgets/projected_item_card.dart';
import 'widgets/projection_summary_header.dart';

class MarketProjectionPage extends ConsumerStatefulWidget {
  const MarketProjectionPage({super.key});

  @override
  ConsumerState<MarketProjectionPage> createState() =>
      _MarketProjectionPageState();
}

class _MarketProjectionPageState extends ConsumerState<MarketProjectionPage> {
  PurchaseType _type = PurchaseType.main;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final projection = ref.watch(marketProjectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Projetar mercado')),
      body: projection.when(
        loading: () => const AppLoadingState(),
        error: (e, _) => AppErrorState(
          message: 'Erro ao montar a projeção',
          onRetry: () => ref.invalidate(marketProjectionProvider),
        ),
        data: _buildBody,
      ),
      bottomNavigationBar: projection.valueOrNull?.isEmpty ?? true
          ? null
          : _buildBottomBar(projection.value!),
    );
  }

  Widget _buildBody(MarketProjection projection) {
    if (projection.isEmpty) {
      return const AppEmptyState(
        icon: Icons.check_circle_outline,
        title: 'Despensa no ideal',
        subtitle: 'Nada abaixo do nível ideal para projetar agora.',
      );
    }

    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? <Category>[];
    final indexOf = {
      for (var i = 0; i < projection.items.length; i++) projection.items[i]: i,
    };
    final groups = groupByCategory<ProjectedItem>(
      items: projection.items,
      categoryIdOf: (item) => item.product.categoryId,
      categories: categories,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) return ProjectionSummaryHeader(projection: projection);
        final group = groups[i - 1];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            CategorySectionHeader(category: group.category),
            const SizedBox(height: 8),
            ...group.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProjectedItemCard(
                  item: item,
                  category: group.category,
                  onIncrement: () => _notifier.increment(indexOf[item]!),
                  onDecrement: () => _notifier.decrement(indexOf[item]!),
                  onRemove: () => _notifier.removeItem(indexOf[item]!),
                  onTogglePicked: () => _togglePicked(indexOf[item]!, item),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(MarketProjection projection) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<PurchaseType>(
              segments: const [
                ButtonSegment(value: PurchaseType.main, label: Text('Mensal')),
                ButtonSegment(
                  value: PurchaseType.midMonth,
                  label: Text('Avulsa'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _saving ? null : () => _confirm(projection),
              icon: const Icon(Icons.push_pin_outlined),
              label: Text('Cravar ${projection.totalItems} itens'),
            ),
          ],
        ),
      ),
    );
  }

  MarketProjectionNotifier get _notifier =>
      ref.read(marketProjectionProvider.notifier);

  Future<void> _togglePicked(int index, ProjectedItem item) async {
    if (item.picked) {
      final confirmed = await SlideConfirmDialog.show(
        context,
        title: 'Tirar do carrinho?',
        message:
            '"${item.product.name}" volta para a lista de itens a pegar. Arraste para confirmar.',
        slideLabel: 'Arraste para desmarcar',
      );
      if (confirmed == true) _notifier.unpick(index);
      return;
    }
    final result = await ItemPickDialog.show(
      context,
      productName: item.product.name,
      unit: item.product.unit,
      initialQuantity: item.quantity,
      initialUnitPrice: item.unitPrice,
      confirmLabel: 'Salvar',
    );
    if (result == null) return;
    _notifier.pick(
      index,
      quantity: result.quantity,
      unitPrice: result.unitPrice,
    );
  }

  Future<void> _confirm(MarketProjection projection) async {
    setState(() => _saving = true);
    try {
      final purchaseId = await _notifier.confirm(_type);
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => PurchaseDetailPage(purchaseId: purchaseId),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível cravar a compra')),
      );
    }
  }
}
