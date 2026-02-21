import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_providers.dart';
import '../providers/pantry_providers.dart';
import '../shared/widgets/app_loading_state.dart';

class PantryAddPage extends ConsumerStatefulWidget {
  const PantryAddPage({super.key});

  @override
  ConsumerState<PantryAddPage> createState() => _PantryAddPageState();
}

class _PantryAddPageState extends ConsumerState<PantryAddPage> {
  String? _selectedProductId;
  final _currentQtyController = TextEditingController(text: '0');
  final _idealQtyController = TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _currentQtyController.dispose();
    _idealQtyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) return;

    await ref.read(pantryProvider.notifier).addItem(
      _selectedProductId!,
      double.tryParse(_currentQtyController.text) ?? 0,
      double.tryParse(_idealQtyController.text) ?? 1,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final pantryItems = ref.watch(pantryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar à Despensa')),
      body: products.when(
        loading: () => const AppLoadingState(),
        error: (_, _) => const Center(child: Text('Erro ao carregar produtos')),
        data: (prods) {
          final existingProductIds = pantryItems.valueOrNull
              ?.map((i) => i.productId)
              .toSet() ?? {};
          final available = prods
              .where((p) => !existingProductIds.contains(p.id))
              .toList();

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedProductId,
                  decoration: const InputDecoration(labelText: 'Produto'),
                  items: available.map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedProductId = v),
                  validator: (v) => v == null ? 'Selecione um produto' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currentQtyController,
                  decoration: const InputDecoration(labelText: 'Quantidade atual'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return n == null || n < 0 ? 'Informe um valor válido' : null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _idealQtyController,
                  decoration: const InputDecoration(labelText: 'Quantidade ideal'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return n == null || n <= 0 ? 'Informe um valor maior que 0' : null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
