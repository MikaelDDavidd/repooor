import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/nfce/nfce_import_draft.dart';
import '../../../domain/entities/purchase.dart';
import '../../providers/nfce_providers.dart';

class NfceImportFabActions extends ConsumerWidget {
  const NfceImportFabActions({super.key, required this.draft});

  final NfceImportDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(nfceImportProvider.notifier);
    final canImport = draft.isReadyToImport;

    return Material(
      elevation: 8,
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tipo da compra', style: AppTextStyles.bodySecondary),
                  SegmentedButton<PurchaseType>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: PurchaseType.midMonth,
                        label: Text('Avulsa'),
                      ),
                      ButtonSegment(
                        value: PurchaseType.main,
                        label: Text('Mensal'),
                      ),
                    ],
                    selected: {draft.targetType},
                    onSelectionChanged: (s) =>
                        notifier.changeTargetType(s.first),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canImport ? notifier.confirmImport : null,
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: Text(
                    canImport
                        ? 'Importar ${draft.matches.length} itens'
                        : 'Resolva os itens pendentes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
