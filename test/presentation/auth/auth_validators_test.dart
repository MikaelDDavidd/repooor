import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/presentation/auth/auth_validators.dart';

void main() {
  group('email', () {
    test('should reject empty and malformed addresses', () {
      expect(AuthValidators.email(null), 'Informe seu e-mail');
      expect(AuthValidators.email('   '), 'Informe seu e-mail');
      expect(AuthValidators.email('mikael'), 'E-mail inválido');
      expect(AuthValidators.email('mikael@exemplo'), 'E-mail inválido');
    });

    test('should accept a valid address with surrounding spaces', () {
      expect(AuthValidators.email(' mikael@exemplo.com '), isNull);
    });
  });

  group('password', () {
    test('should only require a value on sign in', () {
      expect(AuthValidators.password(''), 'Informe sua senha');
      expect(AuthValidators.password('123'), isNull);
    });

    test('should require eight characters on sign up', () {
      expect(AuthValidators.newPassword(''), 'Informe uma senha');
      expect(
        AuthValidators.newPassword('1234567'),
        'A senha precisa ter pelo menos 8 caracteres',
      );
      expect(AuthValidators.newPassword('12345678'), isNull);
    });
  });

  group('name', () {
    test('should reject blank names', () {
      expect(AuthValidators.name('  '), 'Informe seu nome');
      expect(AuthValidators.name('Mikael'), isNull);
    });
  });
}
