import 'package:khamasiyat_mobile_app/core/errors/api_error.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';

/// Backend success/error envelope:
///
/// ```json
/// { "success": true, "data": {} }
/// { "success": false, "error": { "code", "message", "details", "requestId" } }
/// ```
class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    this.data,
    this.error,
  });

  final bool success;
  final T? data;
  final ApiError? error;

  /// Parses the raw envelope map without decoding `data`.
  factory ApiEnvelope.parse(Map<String, dynamic> json) {
    final success = json['success'];
    if (success is! bool) {
      throw const ParsingException(
        message: 'API envelope missing boolean "success"',
      );
    }

    ApiError? error;
    final errorRaw = json['error'];
    if (errorRaw != null) {
      if (errorRaw is! Map) {
        throw const ParsingException(
          message: 'API envelope "error" must be an object',
        );
      }
      error = ApiError.fromJson(Map<String, dynamic>.from(errorRaw));
    }

    return ApiEnvelope<T>(
      success: success,
      data: json['data'] as T?,
      error: error,
    );
  }

  /// Unwraps a successful envelope and maps `data` with [fromJson].
  ///
  /// Throws [ApiException] when `success` is false.
  /// Throws [ParsingException] when the shape is invalid.
  static T unwrap<T>({
    required Map<String, dynamic> json,
    required T Function(Object? raw) fromJson,
  }) {
    final envelope = ApiEnvelope<Object?>.parse(json);
    if (!envelope.success) {
      final error = envelope.error;
      if (error == null) {
        throw const ParsingException(
          message: 'API envelope success=false without error object',
        );
      }
      throw ApiException(error: error);
    }
    return fromJson(envelope.data);
  }

  /// Like [unwrap] but allows a null `data` payload.
  static T? unwrapNullable<T>({
    required Map<String, dynamic> json,
    required T Function(Object? raw) fromJson,
  }) {
    final envelope = ApiEnvelope<Object?>.parse(json);
    if (!envelope.success) {
      final error = envelope.error;
      if (error == null) {
        throw const ParsingException(
          message: 'API envelope success=false without error object',
        );
      }
      throw ApiException(error: error);
    }
    if (envelope.data == null) {
      return null;
    }
    return fromJson(envelope.data);
  }
}
