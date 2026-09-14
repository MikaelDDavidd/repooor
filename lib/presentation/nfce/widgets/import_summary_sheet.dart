import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/nfce/nfce_import_draft.dart';

class ImportSummarySheet extends StatelessWidget {
  const ImportSummarySheet({
    super.key,
    required this.draft,
    required this.onViewPurchase,
    required this.onDone,
    this.reconciled = false,
  });

  final NfceImportDraft draft;
  final VoidCallback onViewPurchase;
  final VoidCallback onDone;
  final bool reconciled;

  @override
  Widget build(BuildContext context) {
    final newProducts = draft.newProductCount;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.primaryStrong,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            reconciled ? 'Compra conciliada!' : 'Compra importada!',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${draft.matches.length} ${draft.matches.length == 1 ? 'item' : 'itens'}'
            '${newProducts > 0 ? ' · $newProducts ${newProducts == 1 ? 'produto novo criado' : 'produtos novos criados'}' : ''}',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          if (draft.invoice.totalPrice != null) ...[
            const SizedBox(height: 8),
            Text(
              'Total ${CurrencyFormatter.formatBrl(draft.invoice.totalPrice)}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primaryStrong,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onViewPurchase,
            icon: const Icon(Icons.visibility),
            label: const Text('Ver compra'),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onDone, child: const Text('Fechar')),
        ],
      ),
    );
  }
}
