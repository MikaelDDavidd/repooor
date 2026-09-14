import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repooor/core/theme/app_theme.dart';
import 'package:repooor/domain/entities/auth/app_user.dart';
import 'package:repooor/presentation/providers/auth_providers.dart';
import 'package:repooor/presentation/splash/splash_page.dart';

const _user = AppUser(
  id: 'user-1',
  email: 'mikael@exemplo.com',
  name: 'Mikael',
);

void main() {
  Widget buildApp(AppUser? user) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('tela de login')),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const Scaffold(body: Text('tela de onboarding')),
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('tela inicial')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [authStateProvider.overrideWith((ref) => Stream.value(user))],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  Future<void> settleSplash(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets('should go to the home screen when the session is alive', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});

    await tester.pumpWidget(buildApp(_user));
    await settleSplash(tester);

    expect(find.text('tela inicial'), findsOneWidget);
  });

  testWidgets('should go to the login screen when there is no session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});

    await tester.pumpWidget(buildApp(null));
    await settleSplash(tester);

    expect(find.text('tela de login'), findsOneWidget);
  });

  testWidgets('should show the onboarding first on a fresh install', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(buildApp(null));
    await settleSplash(tester);

    expect(find.text('tela de onboarding'), findsOneWidget);
  });
}
