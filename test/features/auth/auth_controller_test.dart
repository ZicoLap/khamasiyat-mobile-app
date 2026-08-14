import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/storage/secure_token_store.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_repository.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_tokens.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_auth_remote.dart';

void main() {
  test('AuthController logout clears authenticated state', () async {
    final tokens = InMemoryTokenStore();
    await tokens.saveTokens(accessToken: 'a', refreshToken: 'r');
    final remote = FakeAuthRemote(meUser: buildAuthUser());
    final repository = AuthRepository(api: remote, tokenStore: tokens);
    final controller = AuthController(
      repository: repository,
      restoreOnStart: false,
      initialState: AuthAuthenticated(buildAuthUser()),
    );

    await controller.logout();
    expect(controller.state, isA<AuthUnauthenticated>());
    expect(await tokens.readAccessToken(), isNull);
    expect(remote.logoutCallCount, 1);
  });

  test('AuthController login success becomes authenticated', () async {
    final tokens = InMemoryTokenStore();
    final remote = FakeAuthRemote(
      loginResult: AuthSessionResult(
        tokens: const AuthTokens(accessToken: 'a', refreshToken: 'r'),
        user: buildAuthUser(),
      ),
    );
    final controller = AuthController(
      repository: AuthRepository(api: remote, tokenStore: tokens),
      restoreOnStart: false,
      initialState: const AuthUnauthenticated(),
    );

    await controller.login(email: 'c@example.com', password: 'Password1');
    expect(controller.state, isA<AuthAuthenticated>());
  });
}
