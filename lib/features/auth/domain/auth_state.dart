import 'package:khamasiyat_mobile_app/features/auth/domain/auth_user.dart';

/// Application-level authentication/session state.
sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isInitializing => this is AuthInitializing;
  bool get isUnauthenticated => this is AuthUnauthenticated;

  AuthUser? get userOrNull => switch (this) {
        AuthAuthenticated(:final user) => user,
        AuthRefreshing(:final user) => user,
        _ => null,
      };
}

/// Cold start / secure-storage restoration in progress.
final class AuthInitializing extends AuthState {
  const AuthInitializing();
}

/// No usable customer session.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.messageCode});

  /// Optional localized message key hint (e.g. non-customer rejection).
  final String? messageCode;
}

/// Valid CUSTOMER session.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AuthUser user;
}

/// Session refresh/recovery in progress (optional prior user for UI continuity).
final class AuthRefreshing extends AuthState {
  const AuthRefreshing({this.user});

  final AuthUser? user;
}
