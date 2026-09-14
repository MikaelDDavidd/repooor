import '../../entities/auth/app_user.dart';
import '../../repositories/auth_repository.dart';

class SignIn {
  SignIn(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({required String email, required String password}) =>
      _repository.signIn(email: email, password: password);
}
