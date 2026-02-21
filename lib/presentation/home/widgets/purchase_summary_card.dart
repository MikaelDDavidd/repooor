import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/purchase.dart';
import '../../providers/home_providers.dart';

class PurchaseSummaryCard extends ConsumerWidget {
  const PurchaseSummaryCard({super.key});

  String _typeLabel(PurchaseType type) {
    return switch (type) {
      PurchaseType.main => 'Compra do mes',
      PurchaseType.midMonth => 'Avulsa',
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(purchaseSummaryProvider);

    return Card(
      child: InkWell(
        onTap: () => context.go('/purchases'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: summary.when(
            loading: () => _buildRow('Carregando...'),
            error: (_, _) => _buildRow('Erro ao carregar'),
            data: (data) {
              if (data == null) return _buildRow('Nenhuma compra registrada');
              return _buildRow(
                '${_typeLabel(data.type)} \u00b7 ${_formatDate(data.date)} \u00b7 ${data.itemCount} itens',
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String subtitle) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ultima compra', style: AppTextStyles.heading2),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
