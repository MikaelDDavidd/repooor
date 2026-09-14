import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/core/di/auth_providers.dart';
import 'package:repooor/domain/entities/auth/app_user.dart';
import 'package:repooor/domain/exceptions/auth_exception.dart';
import 'package:repooor/domain/repositories/auth_repository.dart';
import 'package:repooor/presentation/providers/auth_providers.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _user = AppUser(
  id: 'user-1',
  email: 'mikael@exemplo.com',
  name: 'Mikael',
);

void main() {
  late _MockAuthRepository repository;

  setUp(() => repository = _MockAuthRepository());

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('authStateProvider', () {
    test('should emit null and then the user when signing in', () async {
      final controller = StreamController<AppUser?>();
      addTearDown(controller.close);
      when(() => repository.authState).thenAnswer((_) => controller.stream);

      final container = buildContainer();
      final emitted = <AppUser?>[];
      container.listen(authStateProvider, (_, next) {
        if (next.hasValue) emitted.add(next.value);
      }, fireImmediately: true);

      controller.add(null);
      await Future<void>.delayed(Duration.zero);
      controller.add(_user);
      await Future<void>.delayed(Duration.zero);

      expect(emitted, [null, _user]);
    });

    test('should emit null when the user signs out', () async {
      final controller = StreamController<AppUser?>();
      addTearDown(controller.close);
      when(() => repository.authState).thenAnswer((_) => controller.stream);

      final container = buildContainer();
      final emitted = <AppUser?>[];
      container.listen(authStateProvider, (_, next) {
        if (next.hasValue) emitted.add(next.value);
      }, fireImmediately: true);

      controller.add(_user);
      await Future<void>.delayed(Duration.zero);
      controller.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(emitted, [_user, null]);
    });
  });

  group('AuthController', () {
    setUp(() {
      when(() => repository.authState).thenAnswer((_) => const Stream.empty());
    });

    test(
      'should return null and settle on data when sign in succeeds',
      () async {
        when(
          () => repository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => _user);

        final container = buildContainer();
        final failure = await container
            .read(authControllerProvider.notifier)
            .signIn(email: 'mikael@exemplo.com', password: 'senha12345');

        expect(failure, isNull);
        expect(container.read(authControllerProvider).hasError, isFalse);
      },
    );

    test('should return the failure when sign in is rejected', () async {
      when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException.invalidCredentials());

      final container = buildContainer();
      final failure = await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'mikael@exemplo.com', password: 'errada');

      expect(failure?.reason, AuthFailureReason.invalidCredentials);
      expect(container.read(authControllerProvider).hasError, isTrue);
    });

    test('should map an unexpected error to the generic failure', () async {
      when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(StateError('boom'));

      final container = buildContainer();
      final failure = await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'mikael@exemplo.com', password: 'senha12345');

      expect(failure?.reason, AuthFailureReason.unknown);
    });

    test('should report loading while the sign up is pending', () async {
      final completer = Completer<AppUser>();
      when(
        () => repository.signUp(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => completer.future);

      final container = buildContainer();
      final pending = container
          .read(authControllerProvider.notifier)
          .signUp(
            name: 'Mikael',
            email: 'mikael@exemplo.com',
            password: 'senha12345',
          );

      expect(container.read(authControllerProvider).isLoading, isTrue);

      completer.complete(_user);
      expect(await pending, isNull);
      expect(container.read(authControllerProvider).isLoading, isFalse);
    });

    test('should return null when sign out succeeds', () async {
      when(() => repository.signOut()).thenAnswer((_) async {});

      final container = buildContainer();

      expect(
        await container.read(authControllerProvider.notifier).signOut(),
        isNull,
      );
      verify(() => repository.signOut()).called(1);
    });
  });
}
