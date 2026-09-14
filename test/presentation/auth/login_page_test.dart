import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/core/di/auth_providers.dart';
import 'package:repooor/core/theme/app_theme.dart';
import 'package:repooor/domain/entities/auth/app_user.dart';
import 'package:repooor/domain/exceptions/auth_exception.dart';
import 'package:repooor/domain/usecases/auth/sign_in.dart';
import 'package:repooor/presentation/auth/login_page.dart';
import 'package:repooor/presentation/providers/auth_providers.dart';

class _MockSignIn extends Mock implements SignIn {}

const _user = AppUser(
  id: 'user-1',
  email: 'mikael@exemplo.com',
  name: 'Mikael',
);

void main() {
  late _MockSignIn signIn;

  setUp(() => signIn = _MockSignIn());

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(
          path: '/signup',
          builder: (_, _) => const Scaffold(body: Text('tela de cadastro')),
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('tela inicial')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        signInProvider.overrideWithValue(signIn),
        authStateProvider.overrideWith((ref) => const Stream.empty()),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  Future<void> fillForm(
    WidgetTester tester, {
    String email = 'mikael@exemplo.com',
    String password = 'senha12345',
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
  }

  testWidgets('should show field errors when submitting empty', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
    verifyNever(
      () => signIn.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('should reject a malformed e-mail before calling the use case', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    await fillForm(tester, email: 'mikael');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail inválido'), findsOneWidget);
    verifyNever(
      () => signIn.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('should show a readable message when credentials are wrong', (
    tester,
  ) async {
    when(
      () => signIn.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AuthException.invalidCredentials());

    await tester.pumpWidget(buildApp());
    await fillForm(tester, password: 'errada');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou senha incorretos'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('should show a connection message when there is no network', (
    tester,
  ) async {
    when(
      () => signIn.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AuthException.network());

    await tester.pumpWidget(buildApp());
    await fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(
      find.text('Sem conexão com o servidor. Verifique sua internet'),
      findsOneWidget,
    );
  });

  testWidgets('should show loading and block the button while signing in', (
    tester,
  ) async {
    final completer = Completer<AppUser>();
    when(
      () => signIn.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildApp());
    await fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    completer.complete(_user);
    await tester.pumpAndSettle();
  });

  testWidgets('should go to the home screen after signing in', (tester) async {
    when(
      () => signIn.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => _user);

    await tester.pumpWidget(buildApp());
    await fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('tela inicial'), findsOneWidget);
    verify(
      () => signIn.call(email: 'mikael@exemplo.com', password: 'senha12345'),
    ).called(1);
  });

  testWidgets('should open the sign up screen from the link', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Ainda não tem conta? Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('tela de cadastro'), findsOneWidget);
  });
}
