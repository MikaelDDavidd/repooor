import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  const CategoryFormDialog({super.key, this.category});

  final Category? category;

  static Future<void> show(BuildContext context, {Category? category}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CategoryFormDialog(category: category),
      ),
    );
  }

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late int _selectedIcon;
  late int _selectedColor;

  bool get _isEditing => widget.category != null;

  static const _availableIcons = [
    Icons.apple,
    Icons.eco,
    Icons.set_meal,
    Icons.egg_alt,
    Icons.local_drink,
    Icons.cleaning_services,
    Icons.sanitizer,
    Icons.grain,
    Icons.ac_unit,
    Icons.category,
    Icons.bakery_dining,
    Icons.cookie,
    Icons.coffee,
    Icons.local_pizza,
    Icons.icecream,
    Icons.pets,
  ];

  static const _availableColors = [
    Color(0xFFE74C3C),
    Color(0xFF27AE60),
    Color(0xFFC0392B),
    Color(0xFFF39C12),
    Color(0xFF3498DB),
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
    Color(0xFFE67E22),
    Color(0xFF2980B9),
    Color(0xFF95A5A6),
    Color(0xFFE91E63),
    Color(0xFF607D8B),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.icon ?? Icons.category.codePoint;
    _selectedColor = widget.category?.color ?? _availableColors.first.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(categoriesProvider.notifier);

    if (_isEditing) {
      await notifier.edit(widget.category!.copyWith(
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
      ));
    } else {
      await notifier.add(
        _nameController.text.trim(),
        _selectedIcon,
        _selectedColor,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
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
              _isEditing ? 'Editar Categoria' : 'Nova Categoria',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome da categoria'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 20),
            const Text('Ícone'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((icon) {
                final isSelected = icon.codePoint == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon.codePoint),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Cor'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = color.toARGB32() == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color.toARGB32()),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.textPrimary, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Salvar' : 'Criar Categoria'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
