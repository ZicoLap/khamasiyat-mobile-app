import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/config/app_config.dart';
import 'package:khamasiyat_mobile_app/core/config/providers.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/core/errors/error_mapper.dart';
import 'package:khamasiyat_mobile_app/core/network/api_envelope.dart';
import 'package:khamasiyat_mobile_app/core/network/api_logging_interceptor.dart';
import 'package:khamasiyat_mobile_app/core/network/auth_interceptor.dart';
import 'package:khamasiyat_mobile_app/core/network/auth_refresh_interceptor.dart';
import 'package:khamasiyat_mobile_app/core/network/token_refresher.dart';
import 'package:khamasiyat_mobile_app/core/storage/token_store.dart';
import 'package:khamasiyat_mobile_app/core/storage/token_store_provider.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_api.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_repository.dart';

final errorMapperProvider = Provider<ErrorMapper>((ref) {
  return const ErrorMapper();
});

final tokenRefresherProvider = Provider<TokenRefresher>((ref) {
  final config = ref.watch(appConfigProvider);
  return TokenRefresher(
    bareDio: _createBareDio(config),
    tokenStore: ref.watch(tokenStoreProvider),
    errorMapper: ref.watch(errorMapperProvider),
  );
});

final authRefreshInterceptorProvider = Provider<AuthRefreshInterceptor>((ref) {
  return AuthRefreshInterceptor(
    tokenStore: ref.watch(tokenStoreProvider),
    refresher: ref.watch(tokenRefresherProvider),
  );
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  final refreshInterceptor = ref.watch(authRefreshInterceptorProvider);

  final dio = createDio(
    config: config,
    tokenStore: tokenStore,
    refreshInterceptor: refreshInterceptor,
  );
  refreshInterceptor.dio = dio;
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    dio: ref.watch(dioProvider),
    errorMapper: ref.watch(errorMapperProvider),
  );
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(authApiProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

Dio _createBareDio(AppConfig config) {
  return Dio(
    BaseOptions(
      baseUrl: config.apiRoot,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );
}

/// Builds the shared Dio instance with auth, refresh, and safe logging.
Dio createDio({
  required AppConfig config,
  required TokenStore tokenStore,
  AuthRefreshInterceptor? refreshInterceptor,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiRoot,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(AuthInterceptor(tokenStore: tokenStore));
  if (refreshInterceptor != null) {
    dio.interceptors.add(refreshInterceptor);
  }
  dio.interceptors.add(
    ApiLoggingInterceptor(enableLogging: config.enableNetworkLogging),
  );

  return dio;
}

/// Centralized HTTP client that unwraps the backend API envelope.
class ApiClient {
  ApiClient({
    required Dio dio,
    required ErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final ErrorMapper _errorMapper;

  Future<T> get<T>(
    String path, {
    required T Function(Object? json) fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  Future<T> post<T>(
    String path, {
    required T Function(Object? json) fromJson,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(
      () => _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  Future<T> put<T>(
    String path, {
    required T Function(Object? json) fromJson,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(
      () => _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  Future<T> patch<T>(
    String path, {
    required T Function(Object? json) fromJson,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(
      () => _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  Future<T> delete<T>(
    String path, {
    required T Function(Object? json) fromJson,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(
      () => _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  Future<T> _request<T>(
    Future<Response<dynamic>> Function() send, {
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await send();
      final body = response.data;
      if (body is! Map) {
        throw ParsingException(
          message: 'Expected JSON object envelope, got ${body.runtimeType}',
        );
      }
      return ApiEnvelope.unwrap<T>(
        json: Map<String, dynamic>.from(body),
        fromJson: fromJson,
      );
    } on AppException {
      rethrow;
    } on DioException catch (error) {
      throw _errorMapper.fromDio(error);
    } on FormatException catch (error) {
      throw ParsingException(message: error.message, cause: error);
    }
  }
}
