import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/core/di/auth_providers.dart';
import 'package:repooor/core/theme/app_theme.dart';
import 'package:repooor/domain/entities/auth/app_user.dart';
import 'package:repooor/domain/exceptions/auth_exception.dart';
import 'package:repooor/domain/usecases/auth/sign_up.dart';
import 'package:repooor/presentation/auth/signup_page.dart';
import 'package:repooor/presentation/providers/auth_providers.dart';

class _MockSignUp extends Mock implements SignUp {}

const _user = AppUser(
  id: 'user-1',
  email: 'mikael@exemplo.com',
  name: 'Mikael',
);

void main() {
  late _MockSignUp signUp;

  setUp(() => signUp = _MockSignUp());

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/signup',
      routes: [
        GoRoute(path: '/signup', builder: (_, _) => const SignupPage()),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('tela de login')),
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('tela inicial')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        signUpProvider.overrideWithValue(signUp),
        authStateProvider.overrideWith((ref) => const Stream.empty()),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  Future<void> fillForm(
    WidgetTester tester, {
    String name = 'Mikael',
    String email = 'mikael@exemplo.com',
    String password = 'senha12345',
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), name);
    await tester.enterText(find.byType(TextFormField).at(1), email);
    await tester.enterText(find.byType(TextFormField).at(2), password);
  }

  testWidgets('should tell the user the local data stays with the account', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    expect(
      find.textContaining('continuam aqui e passam a ficar salvos'),
      findsOneWidget,
    );
  });

  testWidgets('should require a password with at least eight characters', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    await fillForm(tester, password: '1234567');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(
      find.text('A senha precisa ter pelo menos 8 caracteres'),
      findsOneWidget,
    );
    verifyNever(
      () => signUp.call(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('should show a readable message when the e-mail is taken', (
    tester,
  ) async {
    when(
      () => signUp.call(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AuthException.emailAlreadyExists());

    await tester.pumpWidget(buildApp());
    await fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('Já existe uma conta com esse e-mail'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('should go to the home screen already signed in', (tester) async {
    when(
      () => signUp.call(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => _user);

    await tester.pumpWidget(buildApp());
    await fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('tela inicial'), findsOneWidget);
    verify(
      () => signUp.call(
        name: 'Mikael',
        email: 'mikael@exemplo.com',
        password: 'senha12345',
      ),
    ).called(1);
  });
}
