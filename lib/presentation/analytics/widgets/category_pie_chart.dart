import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/category.dart';
import '../../providers/analytics_providers.dart';
import '../../providers/category_providers.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_error_state.dart';
import '../../shared/widgets/app_loading_state.dart';

class CategoryPieChart extends ConsumerWidget {
  const CategoryPieChart({super.key, this.onCategoryTap});

  final void Function(String categoryId)? onCategoryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consumption = ref.watch(consumptionByCategoryProvider);
    final categories = ref.watch(categoriesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consumo por categoria', style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            consumption.when(
              loading: () => const SizedBox(
                height: 200,
                child: AppLoadingState(),
              ),
              error: (e, _) => AppErrorState(
                message: 'Erro ao carregar dados',
                onRetry: () => ref.invalidate(consumptionByCategoryProvider),
              ),
              data: (data) {
                if (data.isEmpty) {
                  return const SizedBox(
                    height: 150,
                    child: AppEmptyState(
                      icon: Icons.pie_chart_outline,
                      title: 'Sem dados',
                      subtitle: 'Registre compras para ver o consumo',
                    ),
                  );
                }
                return _buildChart(data, categories);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
    Map<String, double> data,
    AsyncValue<List<Category>> categories,
  ) {
    final cats = categories.valueOrNull ?? [];
    final catMap = {for (final c in cats) c.id: c};
    final total = data.values.fold(0.0, (sum, v) => sum + v);
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: entries.map((entry) {
                final cat = catMap[entry.key];
                final color =
                    cat != null ? Color(cat.color) : AppColors.textSecondary;
                final percentage = total > 0 ? (entry.value / total * 100) : 0;
                return PieChartSectionData(
                  value: entry.value,
                  color: color,
                  radius: 50,
                  title: '${percentage.toStringAsFixed(0)}%',
                  titleStyle: AppTextStyles.chartLabel,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...entries.map((entry) {
          final cat = catMap[entry.key];
          final color =
              cat != null ? Color(cat.color) : AppColors.textSecondary;
          return _buildLegendItem(
            color: color,
            name: cat?.name ?? 'Sem categoria',
            value: entry.value,
            categoryId: entry.key,
          );
        }),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String name,
    required double value,
    required String categoryId,
  }) {
    return InkWell(
      onTap:
          onCategoryTap != null ? () => onCategoryTap!(categoryId) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name, style: AppTextStyles.body),
            ),
            Text(
              value.toStringAsFixed(0),
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
