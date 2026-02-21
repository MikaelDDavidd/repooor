import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/product.dart';
import '../providers/pantry_providers.dart';

class PantryEditDialog extends ConsumerStatefulWidget {
  const PantryEditDialog({super.key, required this.item, this.product});

  final PantryItem item;
  final Product? product;

  static Future<void> show(BuildContext context, {required PantryItem item, Product? product}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
          Text(
            widget.product?.name ?? 'Editar item',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
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
          ElevatedButton(
            onPressed: _save,
            child: const Text('Salvar'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
