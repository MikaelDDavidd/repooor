import '../../entities/auth/app_user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUser {
  GetCurrentUser(this._repository);

  final AuthRepository _repository;

  Future<AppUser?> call() => _repository.currentUser();
}
