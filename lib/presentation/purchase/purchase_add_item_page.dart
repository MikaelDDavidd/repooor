import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_providers.dart';
import '../providers/purchase_providers.dart';
import '../shared/widgets/app_loading_state.dart';

class PurchaseAddItemPage extends ConsumerStatefulWidget {
  const PurchaseAddItemPage({super.key, required this.purchaseId});

  final String purchaseId;

  @override
  ConsumerState<PurchaseAddItemPage> createState() => _PurchaseAddItemPageState();
}

class _PurchaseAddItemPageState extends ConsumerState<PurchaseAddItemPage> {
  String? _selectedProductId;
  final _qtyController = TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) return;

    await ref
        .read(purchaseItemsProvider(widget.purchaseId).notifier)
        .addItem(_selectedProductId!, double.tryParse(_qtyController.text) ?? 1);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);

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
              DropdownButtonFormField<String>(
                initialValue: _selectedProductId,
                decoration: const InputDecoration(labelText: 'Produto'),
                items: prods.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(p.name),
                )).toList(),
                onChanged: (v) => setState(() => _selectedProductId = v),
                validator: (v) => v == null ? 'Selecione um produto' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qtyController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
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
