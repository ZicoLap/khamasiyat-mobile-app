import 'package:khamasiyat_mobile_app/core/errors/api_error.dart';

/// Application-level failure hierarchy.
///
/// Features should catch [AppException] (or subtypes) rather than Dio types.
sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.cause,
  });

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// Backend returned `success: false` with a structured error.
final class ApiException extends AppException {
  ApiException({
    required this.error,
    super.cause,
  }) : super(message: error.message);

  final ApiError error;

  String get code => error.code;
  String? get requestId => error.requestId;
}

/// Transport / connectivity / timeout failure (no usable API envelope).
final class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.cause,
    this.isTimeout = false,
    this.isConnectionError = false,
  });

  final bool isTimeout;
  final bool isConnectionError;
}

/// Response shape was unexpected (missing envelope fields, wrong types).
final class ParsingException extends AppException {
  const ParsingException({
    required super.message,
    super.cause,
  });
}

/// Local / client-side validation or invariant failure.
final class ClientException extends AppException {
  const ClientException({
    required super.message,
    super.cause,
  });
}

/// Session is missing or invalid. F1 will map 401 refresh outcomes here.
final class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Authentication required',
    super.cause,
  });
}
