import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_dtos.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_remote_source.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_tokens.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_user.dart';

/// Thin HTTP adapter over backend `/auth/*` and `/users/me`.
class AuthApi implements AuthRemoteSource {
  AuthApi(this._client);

  final ApiClient _client;

  @override
  Future<MessageResponse> registerStart(RegisterStartRequest request) {
    return _client.post(
      '/auth/register/start',
      data: request.toJson(),
      fromJson: MessageResponse.fromJson,
    );
  }

  @override
  Future<MessageResponse> resendOtp(ResendOtpRequest request) {
    return _client.post(
      '/auth/register/resend-otp',
      data: request.toJson(),
      fromJson: MessageResponse.fromJson,
    );
  }

  @override
  Future<AuthSessionResult> registerVerify(RegisterVerifyRequest request) {
    return _client.post(
      '/auth/register/verify',
      data: request.toJson(),
      fromJson: (json) => AuthSessionResult.fromJson(
        Map<String, dynamic>.from(json! as Map),
      ),
    );
  }

  @override
  Future<AuthSessionResult> login(LoginRequest request) {
    return _client.post(
      '/auth/login',
      data: request.toJson(),
      fromJson: (json) => AuthSessionResult.fromJson(
        Map<String, dynamic>.from(json! as Map),
      ),
    );
  }

  @override
  Future<AuthSessionResult> refresh(String refreshToken) {
    return _client.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      fromJson: (json) => AuthSessionResult.fromJson(
        Map<String, dynamic>.from(json! as Map),
      ),
    );
  }

  @override
  Future<MessageResponse> logout(String refreshToken) {
    return _client.post(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
      fromJson: MessageResponse.fromJson,
    );
  }

  @override
  Future<MessageResponse> forgotPassword(ForgotPasswordRequest request) {
    return _client.post(
      '/auth/forgot-password',
      data: request.toJson(),
      fromJson: MessageResponse.fromJson,
    );
  }

  @override
  Future<MessageResponse> resetPassword(ResetPasswordRequest request) {
    return _client.post(
      '/auth/reset-password',
      data: request.toJson(),
      fromJson: MessageResponse.fromJson,
    );
  }

  @override
  Future<MessageResponse> changePassword(ChangePasswordRequest request) {
    return _client.post(
      '/auth/change-password',
      data: request.toJson(),
      fromJson: (json) {
        final map = Map<String, dynamic>.from(json! as Map);
        return MessageResponse(message: map['message'] as String? ?? '');
      },
    );
  }

  @override
  Future<AuthUser> getMe() {
    return _client.get(
      '/users/me',
      fromJson: (json) => AuthUser.fromJson(
        Map<String, dynamic>.from(json! as Map),
      ),
    );
  }

  @override
  Future<AuthUser> updateMe(UpdateMeRequest request) {
    return _client.patch(
      '/users/me',
      data: request.toJson(),
      fromJson: (json) => AuthUser.fromJson(
        Map<String, dynamic>.from(json! as Map),
      ),
    );
  }
}
