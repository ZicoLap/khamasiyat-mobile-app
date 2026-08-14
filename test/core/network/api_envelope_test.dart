import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/errors/api_error.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/core/network/api_envelope.dart';

void main() {
  group('ApiEnvelope.unwrap', () {
    test('unwraps successful data payload', () {
      final result = ApiEnvelope.unwrap<Map<String, dynamic>>(
        json: {
          'success': true,
          'data': {'id': '1', 'name': 'Pitch A'},
        },
        fromJson: (raw) => Map<String, dynamic>.from(raw! as Map),
      );

      expect(result['id'], '1');
      expect(result['name'], 'Pitch A');
    });

    test('preserves backend error code and requestId', () {
      expect(
        () => ApiEnvelope.unwrap<void>(
          json: {
            'success': false,
            'error': {
              'code': 'BOOKING_HOLD_EXPIRED',
              'message': 'Hold expired',
              'details': {'bookingId': 'b1'},
              'requestId': 'req-123',
            },
          },
          fromJson: (_) {},
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'BOOKING_HOLD_EXPIRED')
              .having((e) => e.requestId, 'requestId', 'req-123')
              .having(
                (e) => e.error.details?['bookingId'],
                'details.bookingId',
                'b1',
              ),
        ),
      );
    });

    test('throws ParsingException when success field is missing', () {
      expect(
        () => ApiEnvelope<Object?>.parse(<String, dynamic>{'data': <String, dynamic>{}}),
        throwsA(isA<ParsingException>()),
      );
    });

    test('parses ApiError fromJson', () {
      final error = ApiError.fromJson({
        'code': 'UNAUTHORIZED',
        'message': 'Invalid token',
        'requestId': 'req-9',
      });
      expect(error.code, 'UNAUTHORIZED');
      expect(error.message, 'Invalid token');
      expect(error.requestId, 'req-9');
    });
  });
}
