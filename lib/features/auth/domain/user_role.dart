/// Backend `UserRole` values relevant to the Customer app.
enum UserRole {
  customer,
  owner,
  admin;

  static UserRole fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'CUSTOMER':
        return UserRole.customer;
      case 'OWNER':
        return UserRole.owner;
      case 'ADMIN':
        return UserRole.admin;
      default:
        throw FormatException('Unknown user role: $value');
    }
  }

  String get apiValue {
    switch (this) {
      case UserRole.customer:
        return 'CUSTOMER';
      case UserRole.owner:
        return 'OWNER';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  bool get isCustomer => this == UserRole.customer;
}
