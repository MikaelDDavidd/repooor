import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/spending_providers.dart';
import 'spending_card.dart';

const _monthsPtBr = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

class MonthlySpendingCard extends ConsumerWidget {
  const MonthlySpendingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spending = ref.watch(currentMonthSpendingProvider);
    final monthLabel = _monthsPtBr[DateTime.now().month - 1];

    return spending.when(
      loading: () => SpendingCard(
        label: 'Gasto em $monthLabel',
        value: null,
        subtitle: 'Calculando...',
      ),
      error: (_, _) => SpendingCard(
        label: 'Gasto em $monthLabel',
        value: null,
        subtitle: 'Erro ao calcular',
      ),
      data: (total) => SpendingCard(
        label: 'Gasto em $monthLabel',
        value: total > 0 ? total : null,
        subtitle: total > 0 ? null : 'Sem itens com preço',
      ),
    );
  }
}
