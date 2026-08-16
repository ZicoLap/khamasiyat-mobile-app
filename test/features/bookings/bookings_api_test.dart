import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/core/errors/error_mapper.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_api.dart';

void main() {
  late _RecordingAdapter adapter;
  late BookingsApi api;

  setUp(() {
    adapter = _RecordingAdapter();
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost/api/v1',
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.httpClientAdapter = adapter;
    api = BookingsApi(ApiClient(dio: dio, errorMapper: const ErrorMapper()));
  });

  test('POST /bookings/:id/cancel parses cancelled booking', () async {
    adapter.body = {
      'success': true,
      'data': {
        'id': 'b-1',
        'status': 'CANCELLED',
        'date': '2026-08-14',
        'startTime': '08:00',
        'endTime': '09:00',
        'priceSdg': 15000,
        'currency': 'SDG',
        'slotOccurrenceId': 'occ-1',
        'pitchId': 'p1',
        'stadiumId': 'st1',
        'holdsUntil': null,
        'stadium': {'id': 'st1', 'name': 'Al-Nile Stadium'},
        'pitch': {'id': 'p1', 'name': 'Pitch A', 'type': 'FIVE_A_SIDE'},
      },
    };

    final booking = await api.cancelBooking('b-1');

    expect(adapter.method, 'POST');
    expect(adapter.path, '/bookings/b-1/cancel');
    expect(booking.id, 'b-1');
    expect(booking.status, 'CANCELLED');
    expect(booking.isCancelled, isTrue);
  });

  test(
    'GET /bookings parses pagination, summaries, holdsUntil, payment',
    () async {
      adapter.body = {
        'success': true,
        'data': {
          'items': [
            {
              'id': 'b-1',
              'status': 'PENDING',
              'date': '2026-08-14',
              'startTime': '08:00',
              'endTime': '09:00',
              'priceSdg': 15000,
              'currency': 'SDG',
              'slotOccurrenceId': 'occ-1',
              'pitchId': 'p1',
              'stadiumId': 'st1',
              'holdsUntil': '2026-08-14T08:15:00.000Z',
              'stadium': {'id': 'st1', 'name': 'Al-Nile Stadium'},
              'pitch': {'id': 'p1', 'name': 'Pitch A', 'type': 'FIVE_A_SIDE'},
              'paymentSummary': {
                'id': 'pay-1',
                'status': 'SUBMITTED',
                'method': 'CASH',
                'amountSdg': 15000,
                'currency': 'SDG',
                'hasReceipt': false,
                'rejectionReason': null,
                'submittedAt': '2026-08-14T08:05:00.000Z',
                'confirmedAt': null,
                'rejectedAt': null,
              },
            },
          ],
          'total': 21,
          'page': 1,
          'limit': 20,
        },
      };

      final page = await api.listBookings(
        page: 1,
        limit: 20,
        status: 'PENDING',
      );

      expect(adapter.method, 'GET');
      expect(adapter.path, '/bookings');
      expect(adapter.query?['page'], 1);
      expect(adapter.query?['limit'], 20);
      expect(adapter.query?['status'], 'PENDING');
      expect(page.total, 21);
      expect(page.page, 1);
      expect(page.limit, 20);
      expect(page.hasMore, isTrue);
      expect(page.items, hasLength(1));
      final booking = page.items.single;
      expect(booking.id, 'b-1');
      expect(booking.status, 'PENDING');
      expect(booking.stadiumName, 'Al-Nile Stadium');
      expect(booking.pitchName, 'Pitch A');
      expect(booking.holdsUntil, DateTime.utc(2026, 8, 14, 8, 15));
      expect(booking.paymentSummary?.status, 'SUBMITTED');
      expect(booking.paymentSummary?.method, 'CASH');
    },
  );

  test('GET /bookings omits status when listing all', () async {
    adapter.body = {
      'success': true,
      'data': {'items': <Object>[], 'total': 0, 'page': 1, 'limit': 20},
    };
    await api.listBookings();
    expect(adapter.query?.containsKey('status'), isFalse);
  });

  test(
    'GET /bookings/:id parses hasAccessPin, paymentSummary, check-in',
    () async {
      adapter.body = {
        'success': true,
        'data': {
          'id': 'b-1',
          'status': 'CONFIRMED',
          'date': '2026-08-15',
          'startTime': '20:00',
          'endTime': '21:30',
          'priceSdg': 50000,
          'currency': 'SDG',
          'slotOccurrenceId': 'occ-1',
          'pitchId': 'p1',
          'stadiumId': 'st1',
          'holdsUntil': null,
          'hasAccessPin': true,
          'checkedInAt': null,
          'cancelledAt': null,
          'completedAt': null,
          'stadium': {'id': 'st1', 'name': 'Al-Nile Stadium'},
          'pitch': {'id': 'p1', 'name': 'Pitch Bahri', 'type': 'FIVE_A_SIDE'},
          'paymentSummary': {
            'id': 'pay-1',
            'status': 'CONFIRMED',
            'method': 'BANKAK',
            'amountSdg': 50000,
            'currency': 'SDG',
            'hasReceipt': true,
            'rejectionReason': null,
            'submittedAt': '2026-08-14T08:05:00.000Z',
            'confirmedAt': '2026-08-14T08:20:00.000Z',
            'rejectedAt': null,
          },
        },
      };

      final booking = await api.getBooking('b-1');

      expect(adapter.method, 'GET');
      expect(adapter.path, '/bookings/b-1');
      expect(booking.hasAccessPin, isTrue);
      expect(booking.status, 'CONFIRMED');
      expect(booking.stadiumName, 'Al-Nile Stadium');
      expect(booking.pitchName, 'Pitch Bahri');
      expect(booking.paymentSummary?.status, 'CONFIRMED');
      expect(booking.paymentSummary?.method, 'BANKAK');
      expect(booking.paymentSummary?.amountSdg, 50000);
      expect(booking.paymentSummary?.hasReceipt, isTrue);
      expect(booking.checkedInAt, isNull);
    },
  );

  test('GET /bookings/:id/access-pin parses pin payload', () async {
    adapter.body = {
      'success': true,
      'data': {'bookingId': 'b-1', 'pin': '842157'},
    };

    final result = await api.getAccessPin('b-1');

    expect(adapter.method, 'GET');
    expect(adapter.path, '/bookings/b-1/access-pin');
    expect(result.bookingId, 'b-1');
    expect(result.pin, '842157');
    expect(result.toString(), isNot(contains('842157')));
  });

  test('GET /bookings/:id/access-pin maps PIN_NOT_ISSUED', () async {
    adapter.statusCode = 409;
    adapter.body = {
      'success': false,
      'error': {
        'code': 'PIN_NOT_ISSUED',
        'message': 'Access PIN has not been issued.',
        'requestId': 'r-pin',
      },
    };

    expect(
      api.getAccessPin('b-1'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.code,
          'code',
          'PIN_NOT_ISSUED',
        ),
      ),
    );
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  String? method;
  String? path;
  Map<String, dynamic>? requestJson;
  Map<String, dynamic>? query;
  Map<String, dynamic> body = {'success': true, 'data': null};
  int statusCode = 200;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    method = options.method;
    path = options.path;
    query = Map<String, dynamic>.from(options.queryParameters);
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      final bytes = chunks.expand((c) => c).toList();
      if (bytes.isNotEmpty) {
        requestJson = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      }
    } else if (options.data is Map) {
      requestJson = Map<String, dynamic>.from(options.data as Map);
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}
