import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/period_filter.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/top_products_bar_chart.dart';
import 'widgets/purchase_frequency_line_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analise')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PeriodFilter(),
          const SizedBox(height: 16),
          CategoryPieChart(
            onCategoryTap: (id) => context.push('/analytics/category/$id'),
          ),
          const SizedBox(height: 16),
          TopProductsBarChart(
            onProductTap: (id) => context.push('/analytics/product/$id'),
          ),
          const SizedBox(height: 16),
          const PurchaseFrequencyLineChart(),
        ],
      ),
    );
  }
}
