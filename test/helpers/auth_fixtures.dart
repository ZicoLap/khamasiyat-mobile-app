import 'package:khamasiyat_mobile_app/features/auth/domain/auth_user.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/user_role.dart';

AuthUser buildAuthUser({
  String id = 'u1',
  String name = 'Customer',
  String email = 'customer@example.com',
  String phone = '+249912345678',
  UserRole role = UserRole.customer,
  String status = 'ACTIVE',
  bool emailVerified = true,
  bool mustChangePassword = false,
}) {
  return AuthUser(
    id: id,
    name: name,
    email: email,
    phone: phone,
    role: role,
    status: status,
    emailVerified: emailVerified,
    mustChangePassword: mustChangePassword,
  );
}
