abstract final class AuthValidators {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe seu nome';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu e-mail';
    if (!_emailPattern.hasMatch(email)) return 'E-mail inválido';
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Informe sua senha';
    return null;
  }

  static String? newPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Informe uma senha';
    if (password.length < 8) {
      return 'A senha precisa ter pelo menos 8 caracteres';
    }
    return null;
  }
}
