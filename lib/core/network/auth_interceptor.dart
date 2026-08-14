import 'package:dio/dio.dart';
import 'package:khamasiyat_mobile_app/core/storage/token_store.dart';

/// Injects `Authorization: Bearer <accessToken>` when a session exists.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required TokenStore tokenStore}) : _tokenStore = tokenStore;

  final TokenStore _tokenStore;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Refresh uses the refresh token body, not the (possibly expired) access token.
    if (options.path.contains('/auth/refresh')) {
      handler.next(options);
      return;
    }

    final token = await _tokenStore.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
