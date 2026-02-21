import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/category_providers.dart';
import '../providers/product_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Text(_greeting(), style: AppTextStyles.heading1),
          const SizedBox(height: 4),
          Text('Gerencie sua despensa', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 24),
          _QuickAccessCard(
            icon: Icons.inventory_2_outlined,
            title: 'Produtos',
            subtitle: products.when(
              data: (p) => '${p.length} cadastrados',
              loading: () => 'Carregando...',
              error: (_, _) => 'Erro',
            ),
            onTap: () => context.push('/products'),
          ),
          const SizedBox(height: 12),
          _QuickAccessCard(
            icon: Icons.category_outlined,
            title: 'Categorias',
            subtitle: categories.when(
              data: (c) => '${c.length} categorias',
              loading: () => 'Carregando...',
              error: (_, _) => 'Erro',
            ),
            onTap: () => context.push('/categories'),
          ),
          const SizedBox(height: 12),
          _QuickAccessCard(
            icon: Icons.kitchen_outlined,
            title: 'Despensa',
            subtitle: 'Em breve',
            onTap: () => context.go('/pantry'),
          ),
          const SizedBox(height: 12),
          _QuickAccessCard(
            icon: Icons.shopping_cart_outlined,
            title: 'Nova Compra',
            subtitle: 'Em breve',
            onTap: () => context.go('/purchases'),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading2),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
