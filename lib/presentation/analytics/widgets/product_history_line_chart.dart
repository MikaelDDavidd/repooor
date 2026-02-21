import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/usecases/get_consumption_by_product.dart';

class ProductHistoryLineChart extends StatelessWidget {
  const ProductHistoryLineChart({super.key, required this.points});

  final List<ProductConsumptionPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('Sem historico de compras', style: AppTextStyles.bodySecondary),
        ),
      );
    }
    return SizedBox(
      height: 200,
      child: LineChart(_buildChartData()),
    );
  }

  LineChartData _buildChartData() {
    final spots = points.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.quantity);
    }).toList();

    final maxY = points.fold(0.0, (max, p) => p.quantity > max ? p.quantity : max);

    return LineChartData(
      minY: 0,
      maxY: maxY * 1.2,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
          color: AppColors.border,
          strokeWidth: 0.5,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, _) => Text(
              value.toInt().toString(),
              style: AppTextStyles.caption,
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, _) {
              final index = value.toInt();
              if (index < 0 || index >= points.length) {
                return const SizedBox.shrink();
              }
              final date = points[index].date;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${date.day}/${date.month}',
                  style: AppTextStyles.caption,
                ),
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
    );
  }
}
