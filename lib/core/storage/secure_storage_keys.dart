/// Keys used by secure session storage.
///
/// Never log values associated with these keys.
abstract final class SecureStorageKeys {
  static const accessToken = 'auth.access_token';
  static const refreshToken = 'auth.refresh_token';
}
