import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../providers/category_providers.dart';
import '../providers/product_providers.dart';
import '../providers/purchase_providers.dart';
import '../shared/widgets/app_loading_state.dart';
import '../shared/widgets/product_picker_dialog.dart';
import '../shared/widgets/quantity_field.dart';

class PurchaseAddItemPage extends ConsumerStatefulWidget {
  const PurchaseAddItemPage({super.key, required this.purchaseId});

  final String purchaseId;

  @override
  ConsumerState<PurchaseAddItemPage> createState() => _PurchaseAddItemPageState();
}

class _PurchaseAddItemPageState extends ConsumerState<PurchaseAddItemPage> {
  Product? _selectedProduct;
  final _qtyController = TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) return;

    await ref
        .read(purchaseItemsProvider(widget.purchaseId).notifier)
        .addItem(_selectedProduct!.id, double.tryParse(_qtyController.text) ?? 1);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Item')),
      body: products.when(
        loading: () => const AppLoadingState(),
        error: (_, _) => const Center(child: Text('Erro ao carregar produtos')),
        data: (prods) => Form(
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
                      products: prods,
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
                controller: _qtyController,
                label: 'Quantidade',
                min: 1,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return n == null || n <= 0 ? 'Informe um valor válido' : null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _add,
                child: const Text('Adicionar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
