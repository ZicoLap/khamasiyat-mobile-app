import 'package:khamasiyat_mobile_app/features/auth/domain/user_role.dart';

/// Authenticated user projection from backend auth/users endpoints.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.emailVerified,
    required this.mustChangePassword,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String status;
  final bool emailVerified;
  final bool mustChangePassword;

  bool get isCustomer => role.isCustomer;

  bool get isSuspended => status.toUpperCase() == 'SUSPENDED';

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: UserRole.fromApi(json['role'] as String),
      status: json['status'] as String,
      emailVerified: json['emailVerified'] as bool? ?? false,
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.apiValue,
        'status': status,
        'emailVerified': emailVerified,
        'mustChangePassword': mustChangePassword,
      };

  @override
  bool operator ==(Object other) {
    return other is AuthUser &&
        other.id == id &&
        other.email == email &&
        other.role == role &&
        other.mustChangePassword == mustChangePassword;
  }

  @override
  int get hashCode => Object.hash(id, email, role, mustChangePassword);
}
