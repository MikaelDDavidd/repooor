import 'dart:async';

import 'package:appwrite/appwrite.dart';

import '../../domain/entities/auth/app_user.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_ds.dart';
import '../models/auth/app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._account, this._localDs);

  final Account _account;
  final AuthLocalDs _localDs;
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  Stream<AppUser?> get authState async* {
    yield await currentUser();
    yield* _controller.stream;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return await _loadAndBroadcast();
    } on AppwriteException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return await _loadAndBroadcast();
    } on AppwriteException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (_) {
      // Sair é decisão local: mesmo sem rede a sessão do aparelho é limpa,
      // senão o usuário fica preso logado até a conexão voltar.
    }
    await _localDs.clearCachedUser();
    _controller.add(null);
  }

  @override
  Future<AppUser?> currentUser() async {
    try {
      final model = AppUserModel.fromAppwrite(await _account.get());
      await _localDs.cacheUser(model);
      return model.toEntity();
    } on AppwriteException catch (e) {
      if (_isNetworkError(e)) {
        // Falta de rede não é sessão inválida: mantém o usuário logado pelo
        // cache local para o app continuar servindo os dados do sqflite.
        final cached = await _localDs.getCachedUser();
        return cached?.toEntity();
      }
      await _localDs.clearCachedUser();
      return null;
    }
  }

  void dispose() => _controller.close();

  Future<AppUser> _loadAndBroadcast() async {
    final model = AppUserModel.fromAppwrite(await _account.get());
    await _localDs.cacheUser(model);
    final user = model.toEntity();
    _controller.add(user);
    return user;
  }

  bool _isNetworkError(AppwriteException e) => e.code == null || e.code == 0;

  AuthException _mapError(AppwriteException e) {
    if (_isNetworkError(e)) return const AuthException.network();

    switch (e.type) {
      case 'user_invalid_credentials':
        return const AuthException.invalidCredentials();
      case 'user_already_exists':
      case 'user_email_already_exists':
        return const AuthException.emailAlreadyExists();
      case 'password_personal_data':
      case 'general_password_weak':
        return const AuthException.weakPassword();
      case 'general_rate_limit_exceeded':
        return const AuthException.rateLimited();
      case 'user_unauthorized':
      case 'user_session_not_found':
      case 'general_unauthorized_scope':
        return const AuthException.sessionExpired();
      case 'general_argument_invalid':
        return _mapInvalidArgument(e);
    }

    return switch (e.code) {
      401 => const AuthException.invalidCredentials(),
      409 => const AuthException.emailAlreadyExists(),
      429 => const AuthException.rateLimited(),
      _ => const AuthException.unknown(),
    };
  }

  AuthException _mapInvalidArgument(AppwriteException e) {
    final message = e.message?.toLowerCase() ?? '';
    if (message.contains('password')) return const AuthException.weakPassword();
    if (message.contains('email')) return const AuthException.invalidEmail();
    return const AuthException.unknown();
  }
}
