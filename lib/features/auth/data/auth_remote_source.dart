import 'package:khamasiyat_mobile_app/features/auth/data/auth_dtos.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_tokens.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_user.dart';

/// Remote auth contract (implemented by [AuthApi]).
abstract class AuthRemoteSource {
  Future<MessageResponse> registerStart(RegisterStartRequest request);
  Future<MessageResponse> resendOtp(ResendOtpRequest request);
  Future<AuthSessionResult> registerVerify(RegisterVerifyRequest request);
  Future<AuthSessionResult> login(LoginRequest request);
  Future<AuthSessionResult> refresh(String refreshToken);
  Future<MessageResponse> logout(String refreshToken);
  Future<MessageResponse> forgotPassword(ForgotPasswordRequest request);
  Future<MessageResponse> resetPassword(ResetPasswordRequest request);
  Future<MessageResponse> changePassword(ChangePasswordRequest request);
  Future<AuthUser> getMe();
}
