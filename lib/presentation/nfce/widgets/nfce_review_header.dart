import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/nfce/nfce_invoice.dart';

class NfceReviewHeader extends StatelessWidget {
  const NfceReviewHeader({super.key, required this.invoice});

  final NfceInvoice invoice;

  String _formatDate(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year} ${pad(date.hour)}:${pad(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoice.emitenteNome,
              style: AppTextStyles.heading2,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (invoice.emitenteCnpj.isNotEmpty)
              Text(
                'CNPJ ${invoice.emitenteCnpj}',
                style: AppTextStyles.caption,
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  _formatDate(invoice.issuedAt),
                  style: AppTextStyles.bodySecondary,
                ),
                Text(
                  '${invoice.items.length} ${invoice.items.length == 1 ? 'item' : 'itens'}',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
            if (invoice.totalPrice != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: AppColors.primaryStrong,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Total · ${CurrencyFormatter.formatBrl(invoice.totalPrice)}',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryStrong,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
