import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/analytics_providers.dart';

class PeriodFilter extends ConsumerWidget {
  const PeriodFilter({super.key});

  static const _labels = {
    AnalyticsPeriod.lastMonth: '1M',
    AnalyticsPeriod.threeMonths: '3M',
    AnalyticsPeriod.sixMonths: '6M',
    AnalyticsPeriod.oneYear: '1A',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(analyticsPeriodProvider);

    return Wrap(
      spacing: 8,
      children: AnalyticsPeriod.values.map((period) {
        final isSelected = period == selected;
        return ChoiceChip(
          label: Text(_labels[period]!),
          selected: isSelected,
          onSelected: (_) =>
              ref.read(analyticsPeriodProvider.notifier).state = period,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.backgroundSecondary,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }
}
