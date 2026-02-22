import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/usecases/get_consumption_by_product.dart';
import '../providers/analytics_providers.dart';
import '../providers/category_providers.dart';
import '../providers/product_providers.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/app_loading_state.dart';
import 'widgets/product_history_line_chart.dart';

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);
    final consumption = ref.watch(consumptionByProductProvider(productId));

    final productList = products.valueOrNull?.where((p) => p.id == productId);
    final product = (productList != null && productList.isNotEmpty) ? productList.first : null;
    final categoryList = categories.valueOrNull?.where((c) => c.id == product?.categoryId);
    final category = (categoryList != null && categoryList.isNotEmpty) ? categoryList.first : null;

    return Scaffold(
      appBar: AppBar(title: Text(product?.name ?? 'Produto')),
      body: consumption.when(
        loading: () => const AppLoadingState(),
        error: (_, _) => AppErrorState(
          message: 'Erro ao carregar historico',
          onRetry: () =>
              ref.invalidate(consumptionByProductProvider(productId)),
        ),
        data: (points) => _buildContent(
          product?.name ?? 'Produto',
          category?.name ?? 'Sem categoria',
          points,
        ),
      ),
    );
  }

  Widget _buildContent(
    String productName,
    String categoryName,
    List<ProductConsumptionPoint> points,
  ) {
    final totalPurchased = points.fold(0.0, (sum, p) => sum + p.quantity);
    final avgPerPurchase = points.isNotEmpty ? totalPurchased / points.length : 0.0;
    final lastDate = points.isNotEmpty ? points.last.date : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(productName, categoryName),
        const SizedBox(height: 24),
        Text('Historico de compras', style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        ProductHistoryLineChart(points: points),
        const SizedBox(height: 24),
        _buildStatsRow(totalPurchased, avgPerPurchase, lastDate),
      ],
    );
  }

  Widget _buildHeader(String productName, String categoryName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(productName, style: AppTextStyles.heading1),
        const SizedBox(height: 4),
        Text(categoryName, style: AppTextStyles.bodySecondary),
      ],
    );
  }

  Widget _buildStatsRow(
    double totalPurchased,
    double avgPerPurchase,
    DateTime? lastDate,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total comprado',
            value: totalPurchased.toStringAsFixed(0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Media/compra',
            value: avgPerPurchase.toStringAsFixed(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Ultima compra',
            value: lastDate != null
                ? '${lastDate.day}/${lastDate.month}'
                : '-',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
