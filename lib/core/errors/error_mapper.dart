import 'package:dio/dio.dart';
import 'package:khamasiyat_mobile_app/core/errors/api_error.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/core/network/api_envelope.dart';

/// Converts Dio / transport failures and envelope errors into [AppException].
class ErrorMapper {
  const ErrorMapper();

  AppException fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return NetworkException(
          message: 'Request timed out',
          cause: error,
          isTimeout: true,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Unable to reach the server',
          cause: error,
          isConnectionError: true,
        );
      case DioExceptionType.cancel:
        return const ClientException(message: 'Request was cancelled');
      case DioExceptionType.badResponse:
        return _fromResponse(error.response) ??
            NetworkException(
              message: 'Unexpected server response '
                  '(${error.response?.statusCode ?? 'unknown'})',
              cause: error,
            );
      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Secure connection failed',
          cause: error,
        );
      case DioExceptionType.unknown:
        return NetworkException(
          message: 'Network request failed',
          cause: error,
        );
    }
  }

  AppException? _fromResponse(Response<dynamic>? response) {
    if (response == null) {
      return null;
    }

    final data = response.data;
    if (data is! Map) {
      return null;
    }

    try {
      final envelope =
          ApiEnvelope<Object?>.parse(Map<String, dynamic>.from(data));
      if (!envelope.success && envelope.error != null) {
        return ApiException(error: envelope.error!);
      }
    } on ParsingException {
      // Fall through — try raw error object.
    }

    final errorRaw = data['error'];
    if (errorRaw is Map) {
      return ApiException(
        error: ApiError.fromJson(Map<String, dynamic>.from(errorRaw)),
      );
    }

    if (response.statusCode == 401) {
      return const UnauthorizedException();
    }

    return null;
  }
}
