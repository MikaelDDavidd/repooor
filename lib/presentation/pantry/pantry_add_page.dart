import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../providers/category_providers.dart';
import '../providers/product_providers.dart';
import '../providers/pantry_providers.dart';
import '../shared/widgets/app_loading_state.dart';
import '../shared/widgets/product_picker_dialog.dart';
import '../shared/widgets/quantity_field.dart';

class PantryAddPage extends ConsumerStatefulWidget {
  const PantryAddPage({super.key});

  @override
  ConsumerState<PantryAddPage> createState() => _PantryAddPageState();
}

class _PantryAddPageState extends ConsumerState<PantryAddPage> {
  Product? _selectedProduct;
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
    if (_selectedProduct == null) return;

    await ref.read(pantryProvider.notifier).addItem(
      _selectedProduct!.id,
      double.tryParse(_currentQtyController.text) ?? 0,
      double.tryParse(_idealQtyController.text) ?? 1,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);
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
                FormField<Product>(
                  initialValue: _selectedProduct,
                  validator: (_) => _selectedProduct == null ? 'Selecione um produto' : null,
                  builder: (field) => InkWell(
                    onTap: () async {
                      final cats = categories.valueOrNull ?? [];
                      final result = await ProductPickerDialog.show(
                        context,
                        products: available,
                        categories: cats,
                      );
                      if (result != null) {
                        setState(() => _selectedProduct = result);
                        field.didChange(result);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Produto',
                        errorText: field.errorText,
                        suffixIcon: const Icon(Icons.chevron_right),
                      ),
                      child: Text(
                        _selectedProduct?.name ?? 'Selecione um produto',
                        style: _selectedProduct != null ? null : const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                QuantityField(
                  controller: _currentQtyController,
                  label: 'Quantidade atual',
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return n == null || n < 0 ? 'Informe um valor válido' : null;
                  },
                ),
                const SizedBox(height: 16),
                QuantityField(
                  controller: _idealQtyController,
                  label: 'Quantidade ideal',
                  min: 1,
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
