import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/purchase.dart';
import '../providers/purchase_providers.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/app_loading_state.dart';
import '../shared/widgets/confirm_dialog.dart';
import 'purchase_create_dialog.dart';
import 'purchase_detail_page.dart';

class PurchasePage extends ConsumerWidget {
  const PurchasePage({super.key});

  String _typeLabel(PurchaseType type) {
    return switch (type) {
      PurchaseType.main => 'Compra do mês',
      PurchaseType.midMonth => 'Avulsa',
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchases = ref.watch(purchasesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      body: purchases.when(
        loading: () => const AppLoadingState(),
        error: (e, _) => AppErrorState(
          message: 'Erro ao carregar compras',
          onRetry: () => ref.invalidate(purchasesProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return AppEmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Nenhuma compra',
              subtitle: 'Registre sua primeira compra',
              action: ElevatedButton(
                onPressed: () => PurchaseCreateDialog.show(context),
                child: const Text('Nova compra'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final purchase = items[index];
              return Card(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PurchaseDetailPage(purchaseId: purchase.id),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            purchase.type == PurchaseType.main
                                ? Icons.shopping_cart
                                : Icons.shopping_bag_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_typeLabel(purchase.type), style: AppTextStyles.body),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatDate(purchase.date)} · ${purchase.totalItems} itens',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: AppColors.textSecondary,
                          onPressed: () async {
                            final confirmed = await ConfirmDialog.show(
                              context,
                              title: 'Deletar compra',
                              content: 'Tem certeza? A compra não poderá ser recuperada.',
                              confirmLabel: 'Deletar',
                              isDestructive: true,
                            );
                            if (confirmed == true) {
                              ref.read(purchasesProvider.notifier).remove(purchase.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => PurchaseCreateDialog.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
