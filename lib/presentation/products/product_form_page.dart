import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_units.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../providers/category_providers.dart';
import '../providers/product_providers.dart';
import '../shared/widgets/confirm_dialog.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String? _selectedCategoryId;
  String _selectedUnit = AppUnit.un.name;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _selectedCategoryId = widget.product?.categoryId;
    _selectedUnit = widget.product?.unit ?? AppUnit.un.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;

    final notifier = ref.read(productsProvider.notifier);

    if (_isEditing) {
      await notifier.edit(widget.product!.copyWith(
        name: _nameController.text.trim(),
        categoryId: _selectedCategoryId,
        unit: _selectedUnit,
      ));
    } else {
      await notifier.add(
        _nameController.text.trim(),
        _selectedCategoryId!,
        _selectedUnit,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Deletar produto',
      content: 'Tem certeza que deseja deletar "${widget.product!.name}"?',
      confirmLabel: 'Deletar',
      isDestructive: true,
    );
    if (confirmed == true) {
      await ref.read(productsProvider.notifier).remove(widget.product!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Produto' : 'Novo Produto'),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do produto'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            categories.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Erro ao carregar categorias'),
              data: (cats) => DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: cats.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Row(
                    children: [
                      Icon(
                        IconData(c.icon, fontFamily: 'MaterialIcons'),
                        color: Color(c.color),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(c.name),
                    ],
                  ),
                )).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                validator: (v) => v == null ? 'Selecione uma categoria' : null,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedUnit,
              decoration: const InputDecoration(labelText: 'Unidade'),
              items: AppUnit.values.map((u) => DropdownMenuItem(
                value: u.name,
                child: Text(u.label),
              )).toList(),
              onChanged: (v) => setState(() => _selectedUnit = v ?? AppUnit.un.name),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Salvar' : 'Criar Produto'),
            ),
          ],
        ),
      ),
    );
  }
}
