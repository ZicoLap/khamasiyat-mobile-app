/// Request/response DTOs aligned with NestJS auth contracts.
library;

class RegisterStartRequest {
  const RegisterStartRequest({
    required this.name,
    required this.email,
    required this.phone,
  });

  final String name;
  final String email;
  final String phone;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
      };
}

class RegisterVerifyRequest {
  const RegisterVerifyRequest({
    required this.email,
    required this.otp,
    required this.password,
    required this.confirmPassword,
  });

  final String email;
  final String otp;
  final String password;
  final String confirmPassword;

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
        'password': password,
        'confirmPassword': confirmPassword,
      };
}

class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class ResendOtpRequest {
  const ResendOtpRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}

class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };
}

class ChangePasswordRequest {
  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
}

class MessageResponse {
  const MessageResponse({required this.message});

  final String message;

  factory MessageResponse.fromJson(Object? json) {
    final map = Map<String, dynamic>.from(json! as Map);
    return MessageResponse(message: map['message'] as String? ?? '');
  }
}
