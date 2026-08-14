import 'dart:async';

import 'package:dio/dio.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/core/errors/error_mapper.dart';
import 'package:khamasiyat_mobile_app/core/network/api_envelope.dart';
import 'package:khamasiyat_mobile_app/core/storage/token_store.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_tokens.dart';

/// Performs refresh-token rotation on a bare Dio client (no auth interceptors).
class TokenRefresher {
  TokenRefresher({
    required Dio bareDio,
    required TokenStore tokenStore,
    required ErrorMapper errorMapper,
  })  : _dio = bareDio,
        _tokenStore = tokenStore,
        _errorMapper = errorMapper;

  final Dio _dio;
  final TokenStore _tokenStore;
  final ErrorMapper _errorMapper;

  Completer<AuthTokens>? _inFlight;

  bool get isRefreshInFlight => _inFlight != null;

  /// Rotates tokens. Concurrent callers share one in-flight request.
  Future<AuthTokens> refresh() {
    final existing = _inFlight;
    if (existing != null) {
      return existing.future;
    }

    final completer = Completer<AuthTokens>();
    _inFlight = completer;

    () async {
      try {
        final refreshToken = await _tokenStore.readRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          throw const UnauthorizedException(message: 'No refresh token');
        }

        final response = await _dio.post<dynamic>(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        final body = response.data;
        if (body is! Map) {
          throw const ParsingException(
            message: 'Refresh response missing envelope object',
          );
        }

        final result = ApiEnvelope.unwrap<AuthSessionPayload>(
          json: Map<String, dynamic>.from(body),
          fromJson: (raw) => AuthSessionPayload.fromJson(
            Map<String, dynamic>.from(raw! as Map),
          ),
        );

        final tokens = AuthTokens(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
        );

        await _tokenStore.saveTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );

        completer.complete(tokens);
      } on AppException catch (error, stack) {
        completer.completeError(error, stack);
      } on DioException catch (error, stack) {
        completer.completeError(_errorMapper.fromDio(error), stack);
      } catch (error, stack) {
        completer.completeError(error, stack);
      } finally {
        if (identical(_inFlight, completer)) {
          _inFlight = null;
        }
      }
    }();

    return completer.future;
  }
}

class AuthSessionPayload {
  const AuthSessionPayload({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthSessionPayload.fromJson(Map<String, dynamic> json) {
    return AuthSessionPayload(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
