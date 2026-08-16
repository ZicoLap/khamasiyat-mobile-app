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

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? status,
    bool? emailVerified,
    bool? mustChangePassword,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      emailVerified: emailVerified ?? this.emailVerified,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }

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
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.role == role &&
        other.status == status &&
        other.emailVerified == emailVerified &&
        other.mustChangePassword == mustChangePassword;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        phone,
        role,
        status,
        emailVerified,
        mustChangePassword,
      );
}
