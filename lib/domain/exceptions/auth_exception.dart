enum AuthFailureReason {
  invalidCredentials,
  emailAlreadyExists,
  weakPassword,
  invalidEmail,
  network,
  sessionExpired,
  rateLimited,
  unknown,
}

class AuthException implements Exception {
  const AuthException({required this.reason, required this.message});

  const AuthException.invalidCredentials()
    : reason = AuthFailureReason.invalidCredentials,
      message = 'E-mail ou senha incorretos';

  const AuthException.emailAlreadyExists()
    : reason = AuthFailureReason.emailAlreadyExists,
      message = 'Já existe uma conta com esse e-mail';

  const AuthException.weakPassword()
    : reason = AuthFailureReason.weakPassword,
      message = 'A senha precisa ter pelo menos 8 caracteres';

  const AuthException.invalidEmail()
    : reason = AuthFailureReason.invalidEmail,
      message = 'E-mail inválido';

  const AuthException.network()
    : reason = AuthFailureReason.network,
      message = 'Sem conexão com o servidor. Verifique sua internet';

  const AuthException.sessionExpired()
    : reason = AuthFailureReason.sessionExpired,
      message = 'Sua sessão expirou. Entre de novo';

  const AuthException.rateLimited()
    : reason = AuthFailureReason.rateLimited,
      message = 'Muitas tentativas. Espere um pouco e tente de novo';

  const AuthException.unknown()
    : reason = AuthFailureReason.unknown,
      message = 'Não foi possível concluir. Tente de novo';

  final AuthFailureReason reason;
  final String message;

  @override
  String toString() => 'AuthException: $message';
}
