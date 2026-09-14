import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/nfce/imported_item_match.dart';
import '../../../domain/entities/nfce/match_type.dart';
import 'match_status_chip.dart';

class NfceItemReviewCard extends StatelessWidget {
  const NfceItemReviewCard({
    super.key,
    required this.match,
    required this.onChangeMatch,
  });

  final ImportedItemMatch match;
  final VoidCallback onChangeMatch;

  String get _resolvedName {
    if (match.matchedProduct != null) return match.matchedProduct!.name;
    if (match.newProductName != null) return match.newProductName!;
    return match.source.rawName;
  }

  String get _qtyText {
    final qty = match.resolvedQuantity == match.resolvedQuantity.roundToDouble()
        ? match.resolvedQuantity.toInt().toString()
        : match.resolvedQuantity.toStringAsFixed(3);
    return '$qty ${match.resolvedUnit}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onChangeMatch,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_basket,
                      color: AppColors.primaryStrong,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _resolvedName,
                          style: AppTextStyles.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(_qtyText, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      CurrencyFormatter.formatBrl(match.source.totalPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.body.copyWith(
                        color: match.source.totalPrice == null
                            ? AppColors.textSecondary
                            : AppColors.primaryStrong,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: MatchStatusChip(type: match.type),
              ),
              if (match.type != MatchType.exact) ...[
                const SizedBox(height: 6),
                // Linha própria: com a largura toda disponível o nome da nota
                // trunca com reticências em vez de disputar espaço com o chip.
                Text(
                  'da nota: ${match.source.rawName}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
