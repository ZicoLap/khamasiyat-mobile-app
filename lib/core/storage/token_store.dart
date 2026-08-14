/// Abstraction over platform secure storage for authentication secrets.
///
/// Implementations must use platform secure storage (Keychain / Keystore).
/// Do **not** store access or refresh tokens in SharedPreferences.
abstract class TokenStore {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clearSession();
}
