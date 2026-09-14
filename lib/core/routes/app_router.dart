import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/login_page.dart';
import '../../presentation/auth/signup_page.dart';
import '../../presentation/providers/auth_providers.dart';
import '../../presentation/home/home_page.dart';
import '../../presentation/pantry/pantry_page.dart';
import '../../presentation/purchase/purchase_page.dart';
import '../../presentation/analytics/analytics_page.dart';
import '../../presentation/analytics/category_detail_page.dart';
import '../../presentation/analytics/product_detail_page.dart';
import '../../presentation/products/products_page.dart';
import '../../presentation/categories/categories_page.dart';
import '../../presentation/search/search_page.dart';
import '../../presentation/splash/splash_page.dart';
import '../../presentation/nfce/nfce_import_review_page.dart';
import '../../presentation/nfce/nfce_scan_page.dart';
import '../../presentation/nfce/nfce_unsupported_state_page.dart';
import '../../presentation/onboarding/onboarding_page.dart';
import '../../presentation/settings/settings_page.dart';
import '../routes/shell_scaffold.dart';

const _publicRoutes = {'/splash', '/onboarding', '/login', '/signup'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<Object?>(null);
  ref.listen(authStateProvider, (_, next) => refresh.value = next);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
    routes: _routes,
  );
});

String? _redirect(Ref ref, GoRouterState state) {
  final auth = ref.read(authStateProvider);
  if (auth.isLoading) return null;

  final isSignedIn = auth.valueOrNull != null;
  final isPublic = _publicRoutes.contains(state.matchedLocation);

  if (!isSignedIn && !isPublic) return '/login';
  if (isSignedIn &&
      (state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup')) {
    return '/home';
  }
  return null;
}

final _routes = [
  GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
  GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
  GoRoute(
    path: '/onboarding',
    builder: (context, state) => const OnboardingPage(),
  ),
  GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
  ShellRoute(
    builder: (context, state, child) => ShellScaffold(child: child),
    routes: [
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomePage()),
      ),
      GoRoute(
        path: '/pantry',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: PantryPage()),
      ),
      GoRoute(
        path: '/purchases',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: PurchasePage()),
      ),
      GoRoute(
        path: '/analytics',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AnalyticsPage()),
      ),
    ],
  ),
  GoRoute(path: '/products', builder: (context, state) => const ProductsPage()),
  GoRoute(
    path: '/categories',
    builder: (context, state) => const CategoriesPage(),
  ),
  GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
  GoRoute(
    path: '/analytics/category/:id',
    builder: (context, state) =>
        CategoryDetailPage(categoryId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/analytics/product/:id',
    builder: (context, state) =>
        ProductDetailPage(productId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/nfce/scan',
    builder: (context, state) => const NfceScanPage(),
  ),
  GoRoute(
    path: '/nfce/review',
    builder: (context, state) => const NfceImportReviewPage(),
  ),
  GoRoute(
    path: '/nfce/unsupported/:uf',
    builder: (context, state) =>
        NfceUnsupportedStatePage(uf: state.pathParameters['uf']!),
  ),
];
