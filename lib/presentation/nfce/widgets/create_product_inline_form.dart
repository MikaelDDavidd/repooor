import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_units.dart';
import '../../../core/di/providers.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../providers/category_providers.dart';
import '../../providers/product_providers.dart';

class CreateProductInlineForm extends ConsumerStatefulWidget {
  const CreateProductInlineForm({
    super.key,
    required this.suggestedName,
    required this.suggestedUnit,
    this.suggestedCategoryId,
  });

  final String suggestedName;
  final String suggestedUnit;
  final String? suggestedCategoryId;

  static Future<Product?> show(
    BuildContext context, {
    required String suggestedName,
    required String suggestedUnit,
    String? suggestedCategoryId,
  }) {
    return showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateProductInlineForm(
          suggestedName: suggestedName,
          suggestedUnit: suggestedUnit,
          suggestedCategoryId: suggestedCategoryId,
        ),
      ),
    );
  }

  @override
  ConsumerState<CreateProductInlineForm> createState() => _State();
}

class _State extends ConsumerState<CreateProductInlineForm> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  String? _categoryId;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.suggestedName);
    _categoryId = widget.suggestedCategoryId;
    _unit = widget.suggestedUnit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) return;
    final product = Product(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      categoryId: _categoryId!,
      unit: _unit,
    );
    await ref.read(createProductProvider).call(product);
    ref.invalidate(productsProvider);
    if (mounted) Navigator.of(context).pop(product);
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do produto'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v),
              validator: (v) => v == null ? 'Selecione' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _unit,
              decoration: const InputDecoration(labelText: 'Unidade'),
              items: AppUnit.values
                  .map(
                    (u) =>
                        DropdownMenuItem(value: u.label, child: Text(u.label)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _unit = v ?? AppUnit.un.label),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Criar produto'),
            ),
          ],
        ),
      ),
    );
  }
}
