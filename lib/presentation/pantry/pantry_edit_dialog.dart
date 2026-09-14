import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/product.dart';
import '../providers/pantry_providers.dart';
import '../shared/widgets/app_sheet.dart';

class PantryEditDialog extends ConsumerStatefulWidget {
  const PantryEditDialog({super.key, required this.item, this.product});

  final PantryItem item;
  final Product? product;

  static Future<void> show(
    BuildContext context, {
    required PantryItem item,
    Product? product,
  }) {
    return AppSheet.show<void>(
      context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PantryEditDialog(item: item, product: product),
      ),
    );
  }

  @override
  ConsumerState<PantryEditDialog> createState() => _PantryEditDialogState();
}

class _PantryEditDialogState extends ConsumerState<PantryEditDialog> {
  late final TextEditingController _currentController;
  late final TextEditingController _idealController;

  @override
  void initState() {
    super.initState();
    _currentController = TextEditingController(
      text: widget.item.currentQuantity.toStringAsFixed(0),
    );
    _idealController = TextEditingController(
      text: widget.item.idealQuantity.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _currentController.dispose();
    _idealController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = double.tryParse(_currentController.text);
    final ideal = double.tryParse(_idealController.text);
    if (current == null || ideal == null) return;

    final notifier = ref.read(pantryProvider.notifier);
    await notifier.updateQuantity(widget.item.id, current);
    await notifier.updateIdeal(widget.item.id, ideal);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: widget.product?.name ?? 'Editar item',
      subtitle: 'Ajuste o que você tem e o quanto quer manter',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _currentController,
            decoration: const InputDecoration(labelText: 'Quantidade atual'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _idealController,
            decoration: const InputDecoration(labelText: 'Quantidade ideal'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _save, child: const Text('Salvar')),
        ],
      ),
    );
  }
}
