import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/core/errors/error_mapper.dart';

void main() {
  const mapper = ErrorMapper();

  test('maps timeout Dio errors to NetworkException', () {
    final exception = mapper.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      ),
    );
    expect(exception, isA<NetworkException>());
    expect((exception as NetworkException).isTimeout, isTrue);
  });

  test('maps connection errors', () {
    final exception = mapper.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(exception, isA<NetworkException>());
    expect((exception as NetworkException).isConnectionError, isTrue);
  });

  test('maps envelope error from bad response body', () {
    final exception = mapper.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 400,
          data: {
            'success': false,
            'error': {
              'code': 'VALIDATION_ERROR',
              'message': 'Invalid',
              'requestId': 'r1',
            },
          },
        ),
      ),
    );
    expect(exception, isA<ApiException>());
    expect((exception as ApiException).code, 'VALIDATION_ERROR');
    expect(exception.requestId, 'r1');
  });
}
