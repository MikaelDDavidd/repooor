import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/nfce/nfce_import_draft.dart';

class ImportProgressIndicator extends StatelessWidget {
  const ImportProgressIndicator({super.key, required this.draft});

  final NfceImportDraft draft;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(color: AppColors.primaryStrong),
            ),
            const SizedBox(height: 24),
            Text('Importando compra...', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            if (draft.newProductCount > 0)
              Text(
                'Criando ${draft.newProductCount} ${draft.newProductCount == 1 ? 'produto novo' : 'produtos novos'}',
                style: AppTextStyles.bodySecondary,
              ),
            const SizedBox(height: 4),
            Text(
              'Lançando ${draft.matches.length} ${draft.matches.length == 1 ? 'item' : 'itens'}',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
