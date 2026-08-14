import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_dtos.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_repository.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_user.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/non_customer_exception.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final controller = AuthController(
    repository: ref.watch(authRepositoryProvider),
    restoreOnStart: false,
  );

  final refreshInterceptor = ref.read(authRefreshInterceptorProvider);
  refreshInterceptor.onSessionInvalidated = controller.handleSessionInvalidated;
  ref.onDispose(() {
    refreshInterceptor.onSessionInvalidated = null;
  });

  // Wire invalidation callback before restoration starts.
  unawaited(controller.restoreSession());
  return controller;
});

/// Global auth/session notifier.
class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AuthRepository repository,
    bool restoreOnStart = true,
    AuthState initialState = const AuthInitializing(),
  })  : _repository = repository,
        super(initialState) {
    if (restoreOnStart) {
      unawaited(restoreSession());
    }
  }

  final AuthRepository _repository;

  Future<void> restoreSession() async {
    state = const AuthInitializing();
    try {
      final user = await _repository.restoreSession();
      if (user == null) {
        state = const AuthUnauthenticated();
        return;
      }
      state = AuthAuthenticated(user);
    } on NonCustomerAccountException {
      state = const AuthUnauthenticated(messageCode: 'nonCustomer');
    } on ClientException catch (error) {
      if (error.message == 'ACCOUNT_SUSPENDED') {
        state = const AuthUnauthenticated(messageCode: 'accountSuspended');
      } else {
        state = const AuthUnauthenticated();
      }
    } on NetworkException {
      // Keep tokens; show login until connectivity returns / next cold start.
      state = const AuthUnauthenticated(messageCode: 'network');
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _repository.login(
        LoginRequest(email: email.trim(), password: password),
      );
      state = AuthAuthenticated(user);
      return user;
    } on NonCustomerAccountException {
      state = const AuthUnauthenticated(messageCode: 'nonCustomer');
      rethrow;
    }
  }

  Future<void> registerStart({
    required String name,
    required String email,
    required String phone,
  }) {
    return _repository.registerStart(
      RegisterStartRequest(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
      ),
    );
  }

  Future<void> resendRegistrationOtp(String email) {
    return _repository.resendRegistrationOtp(email.trim());
  }

  Future<AuthUser> registerVerify({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final user = await _repository.registerVerify(
        RegisterVerifyRequest(
          email: email.trim(),
          otp: otp.trim(),
          password: password,
          confirmPassword: confirmPassword,
        ),
      );
      state = AuthAuthenticated(user);
      return user;
    } on NonCustomerAccountException {
      state = const AuthUnauthenticated(messageCode: 'nonCustomer');
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) {
    return _repository.forgotPassword(email.trim());
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.resetPassword(
      ResetPasswordRequest(
        email: email.trim(),
        otp: otp.trim(),
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _repository.changePassword(
      ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    state = const AuthUnauthenticated(messageCode: 'passwordChanged');
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      state = const AuthUnauthenticated();
    }
  }

  void handleSessionInvalidated() {
    if (!mounted) {
      return;
    }
    state = const AuthUnauthenticated(messageCode: 'sessionExpired');
  }

  void clearTransientMessage() {
    final current = state;
    if (current is AuthUnauthenticated && current.messageCode != null) {
      state = const AuthUnauthenticated();
    }
  }
}
