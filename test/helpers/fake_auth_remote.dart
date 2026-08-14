import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_dtos.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_remote_source.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_tokens.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_user.dart';

class FakeAuthRemote implements AuthRemoteSource {
  FakeAuthRemote({
    this.meUser,
    this.loginResult,
    this.registerVerifyResult,
    this.refreshResult,
    this.refreshDelay = Duration.zero,
    this.refreshCallCount = 0,
    this.failGetMeWith,
    this.failRefreshWith,
    this.failLoginWith,
    this.failLogoutWith,
  });

  AuthUser? meUser;
  AuthSessionResult? loginResult;
  AuthSessionResult? registerVerifyResult;
  AuthSessionResult? refreshResult;
  Duration refreshDelay;
  int refreshCallCount;
  int getMeCallCount = 0;
  int logoutCallCount = 0;
  Object? failGetMeWith;
  Object? failRefreshWith;
  Object? failLoginWith;
  Object? failLogoutWith;
  String? lastRefreshToken;
  String? lastLogoutRefreshToken;

  @override
  Future<MessageResponse> registerStart(RegisterStartRequest request) async {
    return const MessageResponse(message: 'started');
  }

  @override
  Future<MessageResponse> resendOtp(ResendOtpRequest request) async {
    return const MessageResponse(message: 'resent');
  }

  @override
  Future<AuthSessionResult> registerVerify(RegisterVerifyRequest request) async {
    final result = registerVerifyResult;
    if (result == null) {
      throw const ClientException(message: 'no register result');
    }
    return result;
  }

  @override
  Future<AuthSessionResult> login(LoginRequest request) async {
    if (failLoginWith != null) {
      throw failLoginWith!;
    }
    final result = loginResult;
    if (result == null) {
      throw const ClientException(message: 'no login result');
    }
    return result;
  }

  @override
  Future<AuthSessionResult> refresh(String refreshToken) async {
    refreshCallCount += 1;
    lastRefreshToken = refreshToken;
    if (refreshDelay > Duration.zero) {
      await Future<void>.delayed(refreshDelay);
    }
    if (failRefreshWith != null) {
      throw failRefreshWith!;
    }
    final result = refreshResult;
    if (result == null) {
      throw const UnauthorizedException();
    }
    return result;
  }

  @override
  Future<MessageResponse> logout(String refreshToken) async {
    logoutCallCount += 1;
    lastLogoutRefreshToken = refreshToken;
    if (failLogoutWith != null) {
      throw failLogoutWith!;
    }
    return const MessageResponse(message: 'logged out');
  }

  @override
  Future<MessageResponse> forgotPassword(ForgotPasswordRequest request) async {
    return const MessageResponse(message: 'sent');
  }

  @override
  Future<MessageResponse> resetPassword(ResetPasswordRequest request) async {
    return const MessageResponse(message: 'reset');
  }

  @override
  Future<MessageResponse> changePassword(ChangePasswordRequest request) async {
    return const MessageResponse(message: 'changed');
  }

  @override
  Future<AuthUser> getMe() async {
    getMeCallCount += 1;
    if (failGetMeWith != null) {
      throw failGetMeWith!;
    }
    final user = meUser;
    if (user == null) {
      throw const UnauthorizedException();
    }
    return user;
  }
}
