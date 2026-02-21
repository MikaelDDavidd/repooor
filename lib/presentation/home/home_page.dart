import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/purchase.dart';
import '../providers/purchase_providers.dart';
import '../purchase/purchase_detail_page.dart';
import 'widgets/greeting_header.dart';
import 'widgets/pantry_summary_card.dart';
import 'widgets/purchase_summary_card.dart';
import 'widgets/low_stock_list.dart';
import 'widgets/missing_items_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const GreetingHeader(),
            const SizedBox(height: 24),
            const PantrySummaryCard(),
            const SizedBox(height: 12),
            const PurchaseSummaryCard(),
            const SizedBox(height: 24),
            _buildNewPurchaseButton(context, ref),
            const SizedBox(height: 24),
            const LowStockList(),
            const SizedBox(height: 16),
            const MissingItemsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewPurchaseButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _createPurchase(context, ref),
        icon: const Icon(Icons.add_shopping_cart, color: AppColors.onPrimary),
        label: Text('Nova compra', style: AppTextStyles.button),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Future<void> _createPurchase(BuildContext context, WidgetRef ref) async {
    final id = await ref
        .read(purchasesProvider.notifier)
        .createNew(PurchaseType.main);
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PurchaseDetailPage(purchaseId: id),
        ),
      );
    }
  }
}
