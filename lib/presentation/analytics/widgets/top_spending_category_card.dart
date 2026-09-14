import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/category.dart';
import '../../providers/category_providers.dart';
import '../../providers/spending_providers.dart';
import 'spending_card.dart';

class TopSpendingCategoryCard extends ConsumerWidget {
  const TopSpendingCategoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spendingByCategory = ref.watch(spendingByCategoryProvider);
    final categories = ref.watch(categoriesProvider);

    return spendingByCategory.when(
      loading: () => const SpendingCard(
        label: 'Categoria mais cara',
        value: null,
        subtitle: 'Calculando...',
        icon: Icons.local_fire_department_outlined,
      ),
      error: (_, _) => const SpendingCard(
        label: 'Categoria mais cara',
        value: null,
        subtitle: 'Erro ao calcular',
        icon: Icons.local_fire_department_outlined,
      ),
      data: (data) => _buildTop(data, categories.valueOrNull ?? []),
    );
  }

  Widget _buildTop(Map<String, double> data, List<Category> categories) {
    if (data.isEmpty) {
      return const SpendingCard(
        label: 'Categoria mais cara',
        value: null,
        subtitle: 'Sem dados no período',
        icon: Icons.local_fire_department_outlined,
      );
    }
    final entry = data.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final match = categories.where((c) => c.id == entry.key);
    final categoryName = match.isEmpty ? 'Categoria' : match.first.name;
    return SpendingCard(
      label: 'Categoria mais cara',
      value: entry.value,
      subtitle: categoryName,
      icon: Icons.local_fire_department_outlined,
    );
  }
}
