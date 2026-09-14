import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/data/datasources/auth_local_ds.dart';
import 'package:repooor/data/models/auth/app_user_model.dart';
import 'package:repooor/data/repositories/auth_repository_impl.dart';
import 'package:repooor/domain/entities/auth/app_user.dart';
import 'package:repooor/domain/exceptions/auth_exception.dart';

class _MockAccount extends Mock implements Account {}

class _MockAuthLocalDs extends Mock implements AuthLocalDs {}

class _FakeAppUserModel extends Fake implements AppUserModel {}

appwrite.User buildAccountUser({
  String id = 'user-1',
  String email = 'mikael@exemplo.com',
  String name = 'Mikael',
}) {
  return appwrite.User(
    $id: id,
    $createdAt: '2026-07-26T00:00:00.000+00:00',
    $updatedAt: '2026-07-26T00:00:00.000+00:00',
    name: name,
    registration: '2026-07-26T00:00:00.000+00:00',
    status: true,
    labels: const [],
    passwordUpdate: '',
    email: email,
    phone: '',
    emailVerification: false,
    phoneVerification: false,
    mfa: false,
    prefs: appwrite.Preferences(data: const {}),
    targets: const [],
    accessedAt: '2026-07-26T00:00:00.000+00:00',
  );
}

appwrite.Session buildSession() {
  return appwrite.Session(
    $id: 'session-1',
    $createdAt: '2026-07-26T00:00:00.000+00:00',
    $updatedAt: '2026-07-26T00:00:00.000+00:00',
    userId: 'user-1',
    expire: '2026-08-26T00:00:00.000+00:00',
    provider: 'email',
    providerUid: 'mikael@exemplo.com',
    providerAccessToken: '',
    providerAccessTokenExpiry: '',
    providerRefreshToken: '',
    ip: '127.0.0.1',
    osCode: '',
    osName: '',
    osVersion: '',
    clientType: '',
    clientCode: '',
    clientName: '',
    clientVersion: '',
    clientEngine: '',
    clientEngineVersion: '',
    deviceName: '',
    deviceBrand: '',
    deviceModel: '',
    countryCode: 'br',
    countryName: 'Brazil',
    current: true,
    factors: const [],
    secret: '',
    mfaUpdatedAt: '',
  );
}

const _user = AppUser(
  id: 'user-1',
  email: 'mikael@exemplo.com',
  name: 'Mikael',
);

void main() {
  setUpAll(() => registerFallbackValue(_FakeAppUserModel()));

  late _MockAccount account;
  late _MockAuthLocalDs localDs;
  late AuthRepositoryImpl repository;

  setUp(() {
    account = _MockAccount();
    localDs = _MockAuthLocalDs();
    repository = AuthRepositoryImpl(account, localDs);
    when(() => localDs.cacheUser(any())).thenAnswer((_) async {});
    when(() => localDs.clearCachedUser()).thenAnswer((_) async {});
    when(() => localDs.getCachedUser()).thenAnswer((_) async => null);
  });

  tearDown(() => repository.dispose());

  group('signIn', () {
    test(
      'should return the user and cache it when credentials are valid',
      () async {
        when(
          () => account.createEmailPasswordSession(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => buildSession());
        when(() => account.get()).thenAnswer((_) async => buildAccountUser());

        final result = await repository.signIn(
          email: 'mikael@exemplo.com',
          password: 'senha12345',
        );

        expect(result, _user);
        verify(() => localDs.cacheUser(any())).called(1);
      },
    );

    test('should throw invalidCredentials when password is wrong', () async {
      when(
        () => account.createEmailPasswordSession(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        AppwriteException(
          'Invalid credentials',
          401,
          'user_invalid_credentials',
        ),
      );

      await expectLater(
        repository.signIn(email: 'mikael@exemplo.com', password: 'errada'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.invalidCredentials,
          ),
        ),
      );
    });

    test('should throw network when there is no connection', () async {
      when(
        () => account.createEmailPasswordSession(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        AppwriteException(
          'ClientException with SocketException: Failed host lookup',
        ),
      );

      await expectLater(
        repository.signIn(email: 'mikael@exemplo.com', password: 'senha12345'),
        throwsA(
          isA<AuthException>()
              .having((e) => e.reason, 'reason', AuthFailureReason.network)
              .having((e) => e.message, 'message', contains('Sem conexão')),
        ),
      );
    });

    test('should throw rateLimited when the server answers 429', () async {
      when(
        () => account.createEmailPasswordSession(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        AppwriteException(
          'Too many requests',
          429,
          'general_rate_limit_exceeded',
        ),
      );

      await expectLater(
        repository.signIn(email: 'mikael@exemplo.com', password: 'senha12345'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.rateLimited,
          ),
        ),
      );
    });
  });

  group('signUp', () {
    test('should create the account and already sign in', () async {
      when(
        () => account.create(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => buildAccountUser());
      when(
        () => account.createEmailPasswordSession(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => buildSession());
      when(() => account.get()).thenAnswer((_) async => buildAccountUser());

      final result = await repository.signUp(
        name: 'Mikael',
        email: 'mikael@exemplo.com',
        password: 'senha12345',
      );

      expect(result, _user);
      verify(
        () => account.createEmailPasswordSession(
          email: 'mikael@exemplo.com',
          password: 'senha12345',
        ),
      ).called(1);
    });

    test('should throw emailAlreadyExists when the e-mail is taken', () async {
      when(
        () => account.create(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenThrow(
        AppwriteException('User already exists', 409, 'user_already_exists'),
      );

      await expectLater(
        repository.signUp(
          name: 'Mikael',
          email: 'mikael@exemplo.com',
          password: 'senha12345',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.emailAlreadyExists,
          ),
        ),
      );
    });

    test('should throw weakPassword when the password is too short', () async {
      when(
        () => account.create(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenThrow(
        AppwriteException(
          'Invalid `password` param: Password must be at least 8 characters',
          400,
          'general_argument_invalid',
        ),
      );

      await expectLater(
        repository.signUp(
          name: 'Mikael',
          email: 'mikael@exemplo.com',
          password: '123',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.weakPassword,
          ),
        ),
      );
    });
  });

  group('currentUser', () {
    test('should return the user when the session is valid', () async {
      when(() => account.get()).thenAnswer((_) async => buildAccountUser());

      expect(await repository.currentUser(), _user);
      verify(() => localDs.cacheUser(any())).called(1);
    });

    test(
      'should return null and clear the cache when the session expired',
      () async {
        when(() => account.get()).thenThrow(
          AppwriteException('Unauthorized', 401, 'user_unauthorized'),
        );

        expect(await repository.currentUser(), isNull);
        verify(() => localDs.clearCachedUser()).called(1);
      },
    );

    test('should keep the cached user when there is no connection', () async {
      when(() => account.get()).thenThrow(
        AppwriteException(
          'ClientException with SocketException: Failed host lookup',
        ),
      );
      when(() => localDs.getCachedUser()).thenAnswer(
        (_) async => const AppUserModel(
          id: 'user-1',
          email: 'mikael@exemplo.com',
          name: 'Mikael',
        ),
      );

      expect(await repository.currentUser(), _user);
      verifyNever(() => localDs.clearCachedUser());
    });

    test('should return null offline when there is no cached user', () async {
      when(() => account.get()).thenThrow(
        AppwriteException(
          'ClientException with SocketException: Failed host lookup',
        ),
      );

      expect(await repository.currentUser(), isNull);
    });
  });

  group('signOut', () {
    test('should delete the session and clear the cache', () async {
      when(
        () => account.deleteSession(sessionId: any(named: 'sessionId')),
      ).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => account.deleteSession(sessionId: 'current')).called(1);
      verify(() => localDs.clearCachedUser()).called(1);
    });

    test(
      'should clear the cache even when the server is unreachable',
      () async {
        when(
          () => account.deleteSession(sessionId: any(named: 'sessionId')),
        ).thenThrow(
          AppwriteException(
            'ClientException with SocketException: Failed host lookup',
          ),
        );

        await repository.signOut();

        verify(() => localDs.clearCachedUser()).called(1);
      },
    );
  });

  group('authState', () {
    test('should emit the current user and then null after signOut', () async {
      when(() => account.get()).thenAnswer((_) async => buildAccountUser());
      when(
        () => account.deleteSession(sessionId: any(named: 'sessionId')),
      ).thenAnswer((_) async {});

      final emitted = <AppUser?>[];
      final subscription = repository.authState.listen(emitted.add);
      await Future<void>.delayed(Duration.zero);

      await repository.signOut();
      await Future<void>.delayed(Duration.zero);

      expect(emitted, [_user, null]);
      await subscription.cancel();
    });

    test('should emit null and then the user after signIn', () async {
      when(() => account.get()).thenAnswer((_) async => buildAccountUser());
      when(
        () => account.createEmailPasswordSession(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => buildSession());

      var signedIn = false;
      when(() => account.get()).thenAnswer((_) async {
        if (!signedIn) {
          throw AppwriteException('Unauthorized', 401, 'user_unauthorized');
        }
        return buildAccountUser();
      });

      final emitted = <AppUser?>[];
      final subscription = repository.authState.listen(emitted.add);
      await Future<void>.delayed(Duration.zero);

      signedIn = true;
      await repository.signIn(
        email: 'mikael@exemplo.com',
        password: 'senha12345',
      );
      await Future<void>.delayed(Duration.zero);

      expect(emitted, [null, _user]);
      await subscription.cancel();
    });
  });
}
