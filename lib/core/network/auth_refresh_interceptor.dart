import 'package:dio/dio.dart';
import 'package:khamasiyat_mobile_app/core/network/token_refresher.dart';
import 'package:khamasiyat_mobile_app/core/storage/token_store.dart';

/// Retries once after a coordinated refresh when the access token is rejected.
///
/// Concurrent 401s share a single [TokenRefresher.refresh] call.
class AuthRefreshInterceptor extends Interceptor {
  AuthRefreshInterceptor({
    required TokenStore tokenStore,
    required TokenRefresher refresher,
  })  : _tokenStore = tokenStore,
        _refresher = refresher;

  final TokenStore _tokenStore;
  final TokenRefresher _refresher;

  /// Set after Dio construction so retries use the same client.
  Dio? dio;

  /// Invoked when refresh definitively fails and the local session is cleared.
  void Function()? onSessionInvalidated;

  static const _retriedExtraKey = 'auth_retried';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final options = err.requestOptions;

    if (status != 401 ||
        _shouldSkipRefresh(options) ||
        options.extra[_retriedExtraKey] == true) {
      handler.next(err);
      return;
    }

    final client = dio;
    if (client == null) {
      handler.next(err);
      return;
    }

    try {
      await _refresher.refresh();
      final access = await _tokenStore.readAccessToken();
      if (access == null || access.isEmpty) {
        await _invalidate();
        handler.next(err);
        return;
      }

      final headers = Map<String, dynamic>.from(options.headers);
      headers['Authorization'] = 'Bearer $access';
      final retryOptions = options.copyWith(
        headers: headers,
        extra: {
          ...options.extra,
          _retriedExtraKey: true,
        },
      );

      final response = await client.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } catch (_) {
      await _invalidate();
      handler.next(err);
    }
  }

  bool _shouldSkipRefresh(RequestOptions options) {
    final path = options.path;
    return path.contains('/auth/refresh') ||
        path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password') ||
        path.contains('/auth/logout');
  }

  Future<void> _invalidate() async {
    await _tokenStore.clearSession();
    onSessionInvalidated?.call();
  }
}
