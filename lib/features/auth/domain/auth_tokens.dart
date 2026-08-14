import 'package:khamasiyat_mobile_app/features/auth/domain/auth_user.dart';

/// Access + refresh token pair returned by login/register/refresh.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

/// Full auth success payload: tokens + user.
class AuthSessionResult {
  const AuthSessionResult({
    required this.tokens,
    required this.user,
  });

  final AuthTokens tokens;
  final AuthUser user;

  factory AuthSessionResult.fromJson(Map<String, dynamic> json) {
    return AuthSessionResult(
      tokens: AuthTokens.fromJson(json),
      user: AuthUser.fromJson(
        Map<String, dynamic>.from(json['user'] as Map),
      ),
    );
  }
}
