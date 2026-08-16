import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/user_role.dart';

import '../../helpers/auth_fixtures.dart';

void main() {
  test('AuthUser equality includes name and phone', () {
    final original = buildAuthUser();
    expect(original, isNot(buildAuthUser(name: 'Other')));
    expect(original, isNot(buildAuthUser(phone: '+249900000000')));
    expect(original.copyWith(name: 'Other').name, 'Other');
    expect(original.copyWith(role: UserRole.owner).isCustomer, isFalse);
  });
}
