import '../../entities/auth/app_user.dart';
import '../../repositories/auth_repository.dart';

class SignUp {
  SignUp(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({
    required String name,
    required String email,
    required String password,
  }) => _repository.signUp(name: name, email: email, password: password);
}
