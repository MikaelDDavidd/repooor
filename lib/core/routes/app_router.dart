import 'package:go_router/go_router.dart';
import '../../presentation/home/home_page.dart';
import '../../presentation/pantry/pantry_page.dart';
import '../../presentation/purchase/purchase_page.dart';
import '../../presentation/analytics/analytics_page.dart';
import '../../presentation/products/products_page.dart';
import '../../presentation/categories/categories_page.dart';
import '../routes/shell_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: '/pantry',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PantryPage(),
          ),
        ),
        GoRoute(
          path: '/purchases',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PurchasePage(),
          ),
        ),
        GoRoute(
          path: '/analytics',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AnalyticsPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductsPage(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesPage(),
    ),
  ],
);
