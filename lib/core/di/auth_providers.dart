import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/appwrite_client.dart';
import '../../data/datasources/auth_local_ds.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/sign_in.dart';
import '../../domain/usecases/auth/sign_out.dart';
import '../../domain/usecases/auth/sign_up.dart';

final appwriteClientProvider = Provider<Client>((_) => createAppwriteClient());

final accountProvider = Provider<Account>(
  (ref) => Account(ref.watch(appwriteClientProvider)),
);

final authLocalDsProvider = Provider<AuthLocalDs>((_) => AuthLocalDs());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = AuthRepositoryImpl(
    ref.watch(accountProvider),
    ref.watch(authLocalDsProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final signInProvider = Provider(
  (ref) => SignIn(ref.watch(authRepositoryProvider)),
);
final signUpProvider = Provider(
  (ref) => SignUp(ref.watch(authRepositoryProvider)),
);
final signOutProvider = Provider(
  (ref) => SignOut(ref.watch(authRepositoryProvider)),
);
final getCurrentUserProvider = Provider(
  (ref) => GetCurrentUser(ref.watch(authRepositoryProvider)),
);
