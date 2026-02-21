import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../../presentation/providers/pantry_providers.dart';

class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/pantry')) return 1;
    if (location.startsWith('/purchases')) return 2;
    if (location.startsWith('/analytics')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/pantry');
      case 2:
        context.go('/purchases');
      case 3:
        context.go('/analytics');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = _currentIndex(context);
    final lowStock = ref.watch(lowStockCountProvider);
    final lowCount = lowStock.valueOrNull ?? 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => _onTap(context, i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: lowCount > 0
                ? Badge(
                    label: Text('$lowCount'),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.kitchen_outlined),
                  )
                : const Icon(Icons.kitchen_outlined),
            activeIcon: lowCount > 0
                ? Badge(
                    label: Text('$lowCount'),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.kitchen),
                  )
                : const Icon(Icons.kitchen),
            label: 'Despensa',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Compras',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Análise',
          ),
        ],
      ),
    );
  }
}
