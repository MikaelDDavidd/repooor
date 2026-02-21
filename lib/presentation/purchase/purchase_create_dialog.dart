import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/purchase.dart';
import '../providers/purchase_providers.dart';
import 'purchase_detail_page.dart';

class PurchaseCreateDialog extends ConsumerStatefulWidget {
  const PurchaseCreateDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const PurchaseCreateDialog(),
    );
  }

  @override
  ConsumerState<PurchaseCreateDialog> createState() => _PurchaseCreateDialogState();
}

class _PurchaseCreateDialogState extends ConsumerState<PurchaseCreateDialog> {
  PurchaseType _type = PurchaseType.main;

  Future<void> _create() async {
    final id = await ref.read(purchasesProvider.notifier).createNew(_type);
    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PurchaseDetailPage(purchaseId: id)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Nova Compra', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          SegmentedButton<PurchaseType>(
            segments: const [
              ButtonSegment(value: PurchaseType.main, label: Text('Mensal')),
              ButtonSegment(value: PurchaseType.midMonth, label: Text('Avulsa')),
            ],
            selected: {_type},
            onSelectionChanged: (v) => setState(() => _type = v.first),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _create,
            child: const Text('Criar compra'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
