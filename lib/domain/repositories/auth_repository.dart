import '../entities/auth/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authState;

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<AppUser?> currentUser();
}
