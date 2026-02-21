import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/analytics_providers.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_error_state.dart';
import '../../shared/widgets/app_loading_state.dart';

class PurchaseFrequencyLineChart extends ConsumerWidget {
  const PurchaseFrequencyLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frequency = ref.watch(purchaseFrequencyProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frequencia de compras', style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            frequency.when(
              loading: () => const SizedBox(
                height: 200,
                child: AppLoadingState(),
              ),
              error: (e, _) => AppErrorState(
                message: 'Erro ao carregar dados',
                onRetry: () => ref.invalidate(purchaseFrequencyProvider),
              ),
              data: (data) {
                if (data.isEmpty) {
                  return const SizedBox(
                    height: 150,
                    child: AppEmptyState(
                      icon: Icons.show_chart,
                      title: 'Sem dados',
                      subtitle: 'Registre compras para ver a frequencia',
                    ),
                  );
                }
                return _buildChart(data);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(Map<String, int> data) {
    final sortedKeys = data.keys.toList()..sort();
    final spots = sortedKeys.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        data[entry.value]!.toDouble(),
      );
    }).toList();

    final maxY = data.values
        .fold(0, (max, v) => v > max ? v : max)
        .toDouble();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY + 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, _) {
                  if (value % 1 != 0) return const SizedBox.shrink();
                  return Text(
                    value.toInt().toString(),
                    style: AppTextStyles.caption,
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= sortedKeys.length) {
                    return const SizedBox.shrink();
                  }
                  final parts = sortedKeys[index].split('-');
                  final month = parts.length > 1 ? parts[1] : '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(month, style: AppTextStyles.caption),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: AppColors.onPrimary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
