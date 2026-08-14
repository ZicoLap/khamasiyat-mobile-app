import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/errors/error_mapper.dart';
import 'package:khamasiyat_mobile_app/core/network/auth_refresh_interceptor.dart';
import 'package:khamasiyat_mobile_app/core/network/token_refresher.dart';
import 'package:khamasiyat_mobile_app/core/storage/secure_token_store.dart';

void main() {
  late InMemoryTokenStore tokens;
  late Dio bareDio;
  late TokenRefresher refresher;

  setUp(() {
    tokens = InMemoryTokenStore();
    bareDio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'));
    refresher = TokenRefresher(
      bareDio: bareDio,
      tokenStore: tokens,
      errorMapper: const ErrorMapper(),
    );
  });

  test('TokenRefresher consolidates concurrent refresh calls', () async {
    await tokens.saveTokens(accessToken: 'old', refreshToken: 'refresh-1');

    var refreshHits = 0;
    bareDio.httpClientAdapter = _CallbackAdapter((options) async {
      if (!options.path.contains('/auth/refresh')) {
        return _jsonResponse(404, {'success': false});
      }
      refreshHits += 1;
      await Future<void>.delayed(const Duration(milliseconds: 40));
      return _jsonResponse(200, {
        'success': true,
        'data': {
          'accessToken': 'access-new',
          'refreshToken': 'refresh-new',
          'user': _customerJson(),
        },
      });
    });

    final results = await Future.wait([
      refresher.refresh(),
      refresher.refresh(),
      refresher.refresh(),
    ]);

    expect(refreshHits, 1);
    expect(results.every((t) => t.accessToken == 'access-new'), isTrue);
    expect(await tokens.readRefreshToken(), 'refresh-new');
  });

  test('AuthRefreshInterceptor retries once after coordinated refresh', () async {
    await tokens.saveTokens(accessToken: 'expired', refreshToken: 'refresh-1');

    final client = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'));
    var protectedHits = 0;
    var refreshHits = 0;

    Future<ResponseBody> handle(RequestOptions options) async {
      if (options.path.contains('/auth/refresh')) {
        refreshHits += 1;
        await tokens.saveTokens(
          accessToken: 'access-new',
          refreshToken: 'refresh-new',
        );
        return _jsonResponse(200, {
          'success': true,
          'data': {
            'accessToken': 'access-new',
            'refreshToken': 'refresh-new',
            'user': _customerJson(),
          },
        });
      }

      protectedHits += 1;
      if (protectedHits == 1) {
        return _jsonResponse(401, {
          'success': false,
          'error': {'code': 'UNAUTHORIZED', 'message': 'expired'},
        });
      }
      return _jsonResponse(200, {
        'success': true,
        'data': _customerJson(),
      });
    }

    bareDio.httpClientAdapter = _CallbackAdapter(handle);
    client.httpClientAdapter = _CallbackAdapter(handle);

    final interceptor = AuthRefreshInterceptor(
      tokenStore: tokens,
      refresher: refresher,
    )..dio = client;
    client.interceptors.add(interceptor);

    final response = await client.get<dynamic>('/users/me');
    expect(response.statusCode, 200);
    expect(protectedHits, 2);
    expect(refreshHits, 1);
    expect(await tokens.readAccessToken(), 'access-new');
  });

  test('AuthRefreshInterceptor clears session when refresh fails', () async {
    await tokens.saveTokens(accessToken: 'expired', refreshToken: 'refresh-1');

    final client = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'));

    Future<ResponseBody> handle(RequestOptions options) async {
      if (options.path.contains('/auth/refresh')) {
        return _jsonResponse(401, {
          'success': false,
          'error': {
            'code': 'INVALID_CREDENTIALS',
            'message': 'Invalid',
          },
        });
      }
      return _jsonResponse(401, {
        'success': false,
        'error': {'code': 'UNAUTHORIZED', 'message': 'expired'},
      });
    }

    bareDio.httpClientAdapter = _CallbackAdapter(handle);
    client.httpClientAdapter = _CallbackAdapter(handle);

    var invalidated = false;
    final interceptor = AuthRefreshInterceptor(
      tokenStore: tokens,
      refresher: refresher,
    )
      ..dio = client
      ..onSessionInvalidated = () => invalidated = true;
    client.interceptors.add(interceptor);

    await expectLater(
      client.get<dynamic>('/users/me'),
      throwsA(isA<DioException>()),
    );
    expect(invalidated, isTrue);
    expect(await tokens.readAccessToken(), isNull);
  });
}

Map<String, dynamic> _customerJson() => {
      'id': 'u1',
      'name': 'C',
      'email': 'c@e.com',
      'phone': '+249912345678',
      'role': 'CUSTOMER',
      'status': 'ACTIVE',
      'emailVerified': true,
      'mustChangePassword': false,
    };

ResponseBody _jsonResponse(int status, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

class _CallbackAdapter implements HttpClientAdapter {
  _CallbackAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }
}
