import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/errors/api_error.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/core/storage/secure_token_store.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_dtos.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_repository.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_tokens.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/non_customer_exception.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/user_role.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_auth_remote.dart';

void main() {
  late InMemoryTokenStore tokens;
  late FakeAuthRemote remote;
  late AuthRepository repository;

  setUp(() {
    tokens = InMemoryTokenStore();
    remote = FakeAuthRemote();
    repository = AuthRepository(api: remote, tokenStore: tokens);
  });

  group('AuthRepository.login', () {
    test('persists tokens for CUSTOMER', () async {
      final user = buildAuthUser();
      remote.loginResult = AuthSessionResult(
        tokens: const AuthTokens(accessToken: 'a1', refreshToken: 'r1'),
        user: user,
      );

      final result = await repository.login(
        const LoginRequest(
          email: 'customer@example.com',
          password: 'Password1',
        ),
      );

      expect(result.role, UserRole.customer);
      expect(await tokens.readAccessToken(), 'a1');
      expect(await tokens.readRefreshToken(), 'r1');
    });

    test('rejects OWNER and clears session', () async {
      remote.loginResult = AuthSessionResult(
        tokens: const AuthTokens(accessToken: 'a1', refreshToken: 'r1'),
        user: buildAuthUser(role: UserRole.owner),
      );

      await expectLater(
        repository.login(
          const LoginRequest(email: 'owner@example.com', password: 'Password1'),
        ),
        throwsA(isA<NonCustomerAccountException>()),
      );
      expect(await tokens.readAccessToken(), isNull);
      expect(await tokens.readRefreshToken(), isNull);
    });

    test('rejects ADMIN and clears session', () async {
      remote.loginResult = AuthSessionResult(
        tokens: const AuthTokens(accessToken: 'a1', refreshToken: 'r1'),
        user: buildAuthUser(role: UserRole.admin),
      );

      await expectLater(
        repository.login(
          const LoginRequest(email: 'admin@example.com', password: 'Password1'),
        ),
        throwsA(isA<NonCustomerAccountException>()),
      );
      expect(await tokens.readAccessToken(), isNull);
    });
  });

  group('AuthRepository.restoreSession', () {
    test('returns null without tokens', () async {
      expect(await repository.restoreSession(), isNull);
    });

    test('restores via getMe when access token works', () async {
      await tokens.saveTokens(accessToken: 'a1', refreshToken: 'r1');
      remote.meUser = buildAuthUser();

      final user = await repository.restoreSession();
      expect(user?.email, 'customer@example.com');
      expect(remote.getMeCallCount, 1);
      expect(remote.refreshCallCount, 0);
    });

    test('refreshes when access expired then returns user', () async {
      await tokens.saveTokens(accessToken: 'old', refreshToken: 'r1');
      remote.failGetMeWith = const UnauthorizedException();
      remote.refreshResult = AuthSessionResult(
        tokens: const AuthTokens(accessToken: 'a2', refreshToken: 'r2'),
        user: buildAuthUser(),
      );

      final user = await repository.restoreSession();
      expect(user?.id, 'u1');
      expect(await tokens.readAccessToken(), 'a2');
      expect(await tokens.readRefreshToken(), 'r2');
      expect(remote.refreshCallCount, 1);
    });

    test('clears session when refresh fails as unauthorized', () async {
      await tokens.saveTokens(accessToken: 'old', refreshToken: 'r1');
      remote.failGetMeWith = const UnauthorizedException();
      remote.failRefreshWith = const UnauthorizedException();

      expect(await repository.restoreSession(), isNull);
      expect(await tokens.readAccessToken(), isNull);
    });
  });

  group('AuthRepository.updateMe', () {
    test('returns updated CUSTOMER name', () async {
      remote.meUser = buildAuthUser();

      final user = await repository.updateMe(
        const UpdateMeRequest(name: 'New Name'),
      );

      expect(user.name, 'New Name');
      expect(remote.updateMeCallCount, 1);
      expect(remote.lastUpdateMeRequest?.name, 'New Name');
    });

    test('rejects OWNER and clears session', () async {
      await tokens.saveTokens(accessToken: 'a1', refreshToken: 'r1');
      remote.meUser = buildAuthUser(role: UserRole.owner);

      await expectLater(
        repository.updateMe(const UpdateMeRequest(name: 'Owner')),
        throwsA(isA<NonCustomerAccountException>()),
      );
      expect(await tokens.readAccessToken(), isNull);
    });
  });

  group('AuthRepository.fetchMe', () {
    test('returns current CUSTOMER', () async {
      remote.meUser = buildAuthUser(name: 'Refreshed');
      final user = await repository.fetchMe();
      expect(user.name, 'Refreshed');
      expect(remote.getMeCallCount, 1);
    });
  });

  group('AuthRepository.logout', () {
    test('calls backend and clears local tokens', () async {
      await tokens.saveTokens(accessToken: 'a1', refreshToken: 'r1');
      await repository.logout();
      expect(remote.logoutCallCount, 1);
      expect(remote.lastLogoutRefreshToken, 'r1');
      expect(await tokens.readAccessToken(), isNull);
    });

    test('clears local tokens even when logout request fails', () async {
      await tokens.saveTokens(accessToken: 'a1', refreshToken: 'r1');
      remote.failLogoutWith = const NetworkException(
        message: 'offline',
        isConnectionError: true,
      );

      await expectLater(repository.logout(), throwsA(isA<NetworkException>()));
      expect(await tokens.readAccessToken(), isNull);
      expect(await tokens.readRefreshToken(), isNull);
    });
  });

  group('backend auth error mapping', () {
    test('ApiException preserves backend code and requestId', () {
      final error = ApiException(
        error: const ApiError(
          code: 'INVALID_OTP',
          message: 'bad',
          requestId: 'req-1',
        ),
      );
      expect(error.code, 'INVALID_OTP');
      expect(error.requestId, 'req-1');
    });
  });
}
