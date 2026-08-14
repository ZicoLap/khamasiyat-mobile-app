/// Thrown when backend authenticates a non-CUSTOMER account.
class NonCustomerAccountException implements Exception {
  const NonCustomerAccountException({required this.role});

  final String role;

  @override
  String toString() => 'NonCustomerAccountException(role: $role)';
}
