import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/core/storage/token_store.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_dtos.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_remote_source.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_tokens.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_user.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/non_customer_exception.dart';

/// Auth orchestration: API + secure token persistence + CUSTOMER gate.
class AuthRepository {
  AuthRepository({
    required AuthRemoteSource api,
    required TokenStore tokenStore,
  })  : _api = api,
        _tokenStore = tokenStore;

  final AuthRemoteSource _api;
  final TokenStore _tokenStore;

  Future<MessageResponse> registerStart(RegisterStartRequest request) {
    return _api.registerStart(request);
  }

  Future<MessageResponse> resendRegistrationOtp(String email) {
    return _api.resendOtp(ResendOtpRequest(email: email));
  }

  Future<AuthUser> registerVerify(RegisterVerifyRequest request) async {
    final result = await _api.registerVerify(request);
    return _persistCustomerSession(result);
  }

  Future<AuthUser> login(LoginRequest request) async {
    final result = await _api.login(request);
    return _persistCustomerSession(result);
  }

  /// Restores a CUSTOMER session from secure storage.
  ///
  /// Returns `null` when no tokens exist.
  /// Does **not** clear tokens on transient network failures.
  Future<AuthUser?> restoreSession() async {
    final access = await _tokenStore.readAccessToken();
    final refresh = await _tokenStore.readRefreshToken();
    final hasAccess = access != null && access.isNotEmpty;
    final hasRefresh = refresh != null && refresh.isNotEmpty;

    if (!hasAccess && !hasRefresh) {
      return null;
    }

    if (hasAccess) {
      try {
        final user = await _api.getMe();
        await _ensureCustomerOrClear(user);
        return user;
      } on NonCustomerAccountException {
        rethrow;
      } on AppException catch (error) {
        if (!_looksLikeExpiredSession(error)) {
          rethrow;
        }
      }
    }

    if (!hasRefresh) {
      await _tokenStore.clearSession();
      return null;
    }

    try {
      final rotated = await refreshSession(refresh);
      return rotated.user;
    } on NonCustomerAccountException {
      rethrow;
    } on AppException catch (error) {
      if (_looksLikeExpiredSession(error)) {
        await _tokenStore.clearSession();
        return null;
      }
      rethrow;
    }
  }

  /// Rotates tokens via backend and persists the new pair atomically.
  Future<AuthSessionResult> refreshSession(String refreshToken) async {
    final result = await _api.refresh(refreshToken);
    await _ensureCustomerOrClear(result.user);
    await _tokenStore.saveTokens(
      accessToken: result.tokens.accessToken,
      refreshToken: result.tokens.refreshToken,
    );
    return result;
  }

  Future<AuthUser> fetchMe() async {
    final user = await _api.getMe();
    await _ensureCustomerOrClear(user);
    return user;
  }

  Future<AuthUser> updateMe(UpdateMeRequest request) async {
    final user = await _api.updateMe(request);
    await _ensureCustomerOrClear(user);
    return user;
  }

  Future<MessageResponse> forgotPassword(String email) {
    return _api.forgotPassword(ForgotPasswordRequest(email: email));
  }

  Future<MessageResponse> resetPassword(ResetPasswordRequest request) {
    return _api.resetPassword(request);
  }

  Future<MessageResponse> changePassword(ChangePasswordRequest request) async {
    final response = await _api.changePassword(request);
    // Backend revokes all refresh tokens; drop local session.
    await _tokenStore.clearSession();
    return response;
  }

  /// Logs out remotely when possible, always clears local session.
  ///
  /// Offline strategy: clear local tokens even if the logout request fails so
  /// this device cannot keep an access token. The server refresh token may
  /// remain until expiry — acceptable for MVP offline logout.
  Future<void> logout() async {
    final refresh = await _tokenStore.readRefreshToken();
    try {
      if (refresh != null && refresh.isNotEmpty) {
        await _api.logout(refresh);
      }
    } finally {
      await _tokenStore.clearSession();
    }
  }

  Future<void> clearLocalSession() => _tokenStore.clearSession();

  Future<AuthUser> _persistCustomerSession(AuthSessionResult result) async {
    await _ensureCustomerOrClear(result.user);
    await _tokenStore.saveTokens(
      accessToken: result.tokens.accessToken,
      refreshToken: result.tokens.refreshToken,
    );
    return result.user;
  }

  Future<void> _ensureCustomerOrClear(AuthUser user) async {
    if (user.isSuspended) {
      await _tokenStore.clearSession();
      throw const ClientException(message: 'ACCOUNT_SUSPENDED');
    }
    if (!user.isCustomer) {
      await _tokenStore.clearSession();
      throw NonCustomerAccountException(role: user.role.apiValue);
    }
  }

  bool _looksLikeExpiredSession(AppException error) {
    if (error is UnauthorizedException) {
      return true;
    }
    if (error is ApiException) {
      return error.code == 'INVALID_CREDENTIALS' ||
          error.code == 'UNAUTHORIZED' ||
          error.code == 'FORBIDDEN';
    }
    return false;
  }
}
