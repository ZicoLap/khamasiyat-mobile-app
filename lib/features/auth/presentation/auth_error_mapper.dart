import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/non_customer_exception.dart';
import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations.dart';

/// Maps infrastructure/auth failures to localized user messages.
String mapAuthError(Object error, AppLocalizations l10n) {
  if (error is NonCustomerAccountException) {
    return l10n.authErrorNonCustomer;
  }
  if (error is NetworkException) {
    if (error.isTimeout) {
      return l10n.authErrorTimeout;
    }
    return l10n.authErrorNetwork;
  }
  if (error is ApiException) {
    return _mapCode(error.code, l10n, fallback: error.message);
  }
  if (error is ClientException) {
    if (error.message == 'ACCOUNT_SUSPENDED') {
      return l10n.authErrorAccountSuspended;
    }
    return error.message;
  }
  if (error is UnauthorizedException) {
    return l10n.authErrorUnauthorized;
  }
  if (error is ParsingException) {
    return l10n.authErrorUnexpected;
  }
  return l10n.authErrorUnexpected;
}

String _mapCode(String code, AppLocalizations l10n, {required String fallback}) {
  switch (code) {
    case 'INVALID_CREDENTIALS':
      return l10n.authErrorInvalidCredentials;
    case 'ACCOUNT_SUSPENDED':
      return l10n.authErrorAccountSuspended;
    case 'INVALID_OTP':
      return l10n.authErrorInvalidOtp;
    case 'OTP_EXPIRED':
      return l10n.authErrorOtpExpired;
    case 'EMAIL_ALREADY_REGISTERED':
      return l10n.authErrorEmailRegistered;
    case 'PHONE_ALREADY_REGISTERED':
      return l10n.authErrorPhoneRegistered;
    case 'EMAIL_NOT_VERIFIED':
      return l10n.authErrorEmailNotVerified;
    case 'RATE_LIMIT_EXCEEDED':
      return l10n.authErrorRateLimited;
    case 'PASSWORD_MISMATCH':
      return l10n.authErrorPasswordMismatch;
    case 'WEAK_PASSWORD':
      return l10n.authErrorWeakPassword;
    case 'MAIL_DELIVERY_FAILED':
      return l10n.authErrorMailFailed;
    case 'MUST_CHANGE_PASSWORD':
      return l10n.authErrorMustChangePassword;
    case 'VALIDATION_ERROR':
      return fallback.isNotEmpty ? fallback : l10n.authErrorValidation;
    case 'FORBIDDEN':
      return l10n.authErrorForbidden;
    default:
      return fallback.isNotEmpty ? fallback : l10n.authErrorUnexpected;
  }
}

String? mapAuthMessageCode(String? code, AppLocalizations l10n) {
  switch (code) {
    case 'nonCustomer':
      return l10n.authErrorNonCustomer;
    case 'accountSuspended':
      return l10n.authErrorAccountSuspended;
    case 'network':
      return l10n.authErrorNetwork;
    case 'sessionExpired':
      return l10n.authErrorSessionExpired;
    case 'passwordChanged':
      return l10n.authPasswordChangedRelogin;
    default:
      return null;
  }
}
