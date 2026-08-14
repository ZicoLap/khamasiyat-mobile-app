import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:khamasiyat_mobile_app/core/storage/secure_storage_keys.dart';
import 'package:khamasiyat_mobile_app/core/storage/token_store.dart';

/// [TokenStore] backed by [FlutterSecureStorage].
class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() {
    return _storage.read(key: SecureStorageKeys.accessToken);
  }

  @override
  Future<String?> readRefreshToken() {
    return _storage.read(key: SecureStorageKeys.refreshToken);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: SecureStorageKeys.accessToken,
      value: accessToken,
    );
    await _storage.write(
      key: SecureStorageKeys.refreshToken,
      value: refreshToken,
    );
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: SecureStorageKeys.accessToken);
    await _storage.delete(key: SecureStorageKeys.refreshToken);
  }
}

/// In-memory [TokenStore] for unit tests. Never use in production.
class InMemoryTokenStore implements TokenStore {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
  }
}
