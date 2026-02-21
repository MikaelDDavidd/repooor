import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/app_loading_state.dart';
import '../shared/widgets/confirm_dialog.dart';
import 'category_form_dialog.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      body: categories.when(
        loading: () => const AppLoadingState(),
        error: (e, _) => AppErrorState(
          message: 'Erro ao carregar categorias',
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (cats) {
          if (cats.isEmpty) {
            return const AppEmptyState(
              icon: Icons.category_outlined,
              title: 'Nenhuma categoria',
              subtitle: 'Adicione categorias para organizar seus produtos',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cats.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final cat = cats[index];
              return _CategoryTile(category: cat);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CategoryFormDialog.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(category.color).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            IconData(category.icon, fontFamily: 'MaterialIcons'),
            color: Color(category.color),
            size: 22,
          ),
        ),
        title: Text(category.name, style: AppTextStyles.body),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: AppColors.textSecondary,
              onPressed: () => CategoryFormDialog.show(context, category: category),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.error,
              onPressed: () async {
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: 'Deletar categoria',
                  content: 'Tem certeza que deseja deletar "${category.name}"?',
                  confirmLabel: 'Deletar',
                  isDestructive: true,
                );
                if (confirmed == true) {
                  ref.read(categoriesProvider.notifier).remove(category.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
