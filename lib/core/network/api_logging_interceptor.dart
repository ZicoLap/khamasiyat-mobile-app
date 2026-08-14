import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Headers that must never appear in development logs.
const _sensitiveHeaderKeys = {
  'authorization',
  'cookie',
  'set-cookie',
  'x-api-key',
};

/// Attaches correlation IDs and optionally logs requests without leaking secrets.
class ApiLoggingInterceptor extends Interceptor {
  ApiLoggingInterceptor({
    required this.enableLogging,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final bool enableLogging;
  final Uuid _uuid;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('X-Request-Id', () => _uuid.v4());
    options.headers.putIfAbsent('Accept', () => 'application/json');

    if (enableLogging) {
      debugPrint(
        '[API] → ${options.method} ${options.uri} '
        'requestId=${options.headers['X-Request-Id']}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (enableLogging) {
      debugPrint(
        '[API] ← ${response.statusCode} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enableLogging) {
      final sanitized = _sanitizeHeaders(err.requestOptions.headers);
      debugPrint(
        '[API] ✕ ${err.type} ${err.requestOptions.uri} '
        'status=${err.response?.statusCode} headers=$sanitized',
      );
    }
    handler.next(err);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: _sensitiveHeaderKeys.contains(entry.key.toLowerCase())
            ? '***'
            : entry.value,
    };
  }
}
