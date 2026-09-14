import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/purchase.dart';
import '../providers/purchase_providers.dart';
import '../shared/widgets/app_sheet.dart';
import 'purchase_detail_page.dart';

class PurchaseCreateDialog extends ConsumerStatefulWidget {
  const PurchaseCreateDialog({super.key});

  static Future<void> show(BuildContext context) {
    return AppSheet.show<void>(
      context,
      builder: (_) => const PurchaseCreateDialog(),
    );
  }

  @override
  ConsumerState<PurchaseCreateDialog> createState() =>
      _PurchaseCreateDialogState();
}

class _PurchaseCreateDialogState extends ConsumerState<PurchaseCreateDialog> {
  PurchaseType _type = PurchaseType.main;

  Future<void> _create() async {
    final id = await ref.read(purchasesProvider.notifier).createNew(_type);
    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => PurchaseDetailPage(purchaseId: id)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: 'Nova compra',
      subtitle: 'Escolha o tipo e comece a adicionar itens',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<PurchaseType>(
            segments: const [
              ButtonSegment(value: PurchaseType.main, label: Text('Mensal')),
              ButtonSegment(
                value: PurchaseType.midMonth,
                label: Text('Avulsa'),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (v) => setState(() => _type = v.first),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _create, child: const Text('Criar compra')),
        ],
      ),
    );
  }
}
