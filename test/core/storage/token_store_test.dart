import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/storage/secure_token_store.dart';

void main() {
  test('InMemoryTokenStore saves and clears session', () async {
    final store = InMemoryTokenStore();

    expect(await store.readAccessToken(), isNull);

    await store.saveTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
    );

    expect(await store.readAccessToken(), 'access');
    expect(await store.readRefreshToken(), 'refresh');

    await store.clearSession();
    expect(await store.readAccessToken(), isNull);
    expect(await store.readRefreshToken(), isNull);
  });
}
