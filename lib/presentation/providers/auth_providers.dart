import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/auth_providers.dart';
import '../../domain/entities/auth/app_user.dart';
import '../../domain/exceptions/auth_exception.dart';

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authState,
);

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<AuthException?> signIn({
    required String email,
    required String password,
  }) {
    return _run(
      () => ref.read(signInProvider)(email: email, password: password),
    );
  }

  Future<AuthException?> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      () => ref.read(signUpProvider)(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<AuthException?> signOut() => _run(() => ref.read(signOutProvider)());

  Future<AuthException?> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return null;
    } on AuthException catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return e;
    } catch (_, stackTrace) {
      const failure = AuthException.unknown();
      state = AsyncError(failure, stackTrace);
      return failure;
    }
  }
}
