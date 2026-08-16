import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/errors/error_mapper.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/payments/data/payments_repository.dart';
import 'package:khamasiyat_mobile_app/features/payments/domain/payment_models.dart';

void main() {
  late _RecordingAdapter adapter;
  late PaymentsApi api;

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
    api = PaymentsApi(ApiClient(dio: dio, errorMapper: const ErrorMapper()));
  });

  group('GET /stadiums/:id/payment-methods', () {
    test('parses empty data array', () async {
      adapter.body = {'success': true, 'data': <Object>[]};
      final methods = await api.listStadiumPaymentMethods('st-1');
      expect(adapter.path, '/stadiums/st-1/payment-methods');
      expect(adapter.method, 'GET');
      expect(methods, isEmpty);
    });

    test('parses CASH, BANKAK, BANK_TRANSFER and nullable account fields',
        () async {
      adapter.body = {
        'success': true,
        'data': [
          {
            'method': 'CASH',
            'bankName': null,
            'accountName': null,
            'accountNumber': null,
            'iban': null,
            'phoneNumber': null,
            'instructions': 'Pay at gate',
          },
          {
            'method': 'BANKAK',
            'bankName': null,
            'accountName': null,
            'accountNumber': null,
            'iban': null,
            'phoneNumber': '+249912000333',
            'instructions': null,
          },
          {
            'method': 'BANK_TRANSFER',
            'bankName': 'Bank of Khartoum',
            'accountName': 'G2 Bank',
            'accountNumber': '456',
            'iban': null,
            'phoneNumber': null,
            'instructions': null,
          },
        ],
      };
      final methods = await api.listStadiumPaymentMethods('st-1');
      expect(methods.map((m) => m.method), [
        StadiumPaymentMethodType.cash,
        StadiumPaymentMethodType.bankak,
        StadiumPaymentMethodType.bankTransfer,
      ]);
      expect(methods[0].instructions, 'Pay at gate');
      expect(methods[0].accountNumber, isNull);
      expect(methods[1].phoneNumber, '+249912000333');
      expect(methods[1].bankName, isNull);
      expect(methods[2].bankName, 'Bank of Khartoum');
      expect(methods[2].accountName, 'G2 Bank');
      expect(methods[2].accountNumber, '456');
      expect(methods[2].iban, isNull);
    });
  });

  group('POST /customer/payments/receipt-uploads', () {
    test('parses upload-intent envelope', () async {
      adapter.body = {
        'success': true,
        'data': {
          'uploadIntentId': 'intent-9',
          'uploadUrl': 'https://storage.example/put',
          'expiresAt': '2026-08-16T10:00:00.000Z',
          'headers': {'Content-Type': 'image/jpeg'},
          'maxBytes': 5242880,
        },
      };
      final intent = await api.createReceiptUploadIntent(
        bookingId: 'b-1',
        method: 'BANKAK',
        contentType: 'image/jpeg',
        sizeBytes: 1200,
      );
      expect(adapter.path, '/customer/payments/receipt-uploads');
      expect(adapter.method, 'POST');
      expect(adapter.requestJson, {
        'bookingId': 'b-1',
        'method': 'BANKAK',
        'contentType': 'image/jpeg',
        'sizeBytes': 1200,
      });
      expect(intent.uploadIntentId, 'intent-9');
      expect(intent.uploadUrl, 'https://storage.example/put');
      expect(intent.headers['Content-Type'], 'image/jpeg');
      expect(intent.maxBytes, 5242880);
      expect(intent.expiresAt, DateTime.utc(2026, 8, 16, 10));
    });
  });

  group('POST /bookings/:id/payments', () {
    test('parses submit response and sends method only for CASH', () async {
      adapter.body = {
        'success': true,
        'data': {
          'id': 'pay-1',
          'bookingId': 'b-1',
          'customerId': 'u-1',
          'stadiumId': 'st-1',
          'method': 'CASH',
          'status': 'SUBMITTED',
          'amountSdg': 15000,
          'currency': 'SDG',
          'reference': null,
          'hasReceipt': false,
          'submittedAt': '2026-08-16T08:05:00.000Z',
          'confirmedAt': null,
          'rejectedAt': null,
          'expiredAt': null,
          'rejectionReason': null,
          'createdAt': '2026-08-16T08:05:00.000Z',
          'updatedAt': '2026-08-16T08:05:00.000Z',
        },
      };
      final payment = await api.submitPayment(
        bookingId: 'b-1',
        method: 'CASH',
        idempotencyKey: 'idem-1',
      );
      expect(adapter.path, '/bookings/b-1/payments');
      expect(adapter.method, 'POST');
      expect(adapter.headers['Idempotency-Key'], 'idem-1');
      expect(adapter.requestJson, {'method': 'CASH'});
      expect(adapter.requestJson!.containsKey('amount'), isFalse);
      expect(adapter.requestJson!.containsKey('amountSdg'), isFalse);
      expect(adapter.requestJson!.containsKey('storageKey'), isFalse);
      expect(payment.id, 'pay-1');
      expect(payment.status, 'SUBMITTED');
      expect(payment.method, StadiumPaymentMethodType.cash);
      expect(payment.hasReceipt, isFalse);
      expect(payment.reference, isNull);
    });
  });

  group('GET /payments/:id', () {
    test('parses payment read response including rejectionReason', () async {
      adapter.body = {
        'success': true,
        'data': {
          'id': 'pay-9',
          'bookingId': 'b-1',
          'customerId': 'u-1',
          'stadiumId': 'st-1',
          'method': 'BANKAK',
          'status': 'REJECTED',
          'amountSdg': 15000,
          'currency': 'SDG',
          'reference': 'REF-1',
          'hasReceipt': true,
          'submittedAt': '2026-08-16T08:05:00.000Z',
          'confirmedAt': null,
          'rejectedAt': '2026-08-16T08:10:00.000Z',
          'expiredAt': null,
          'rejectionReason': 'Blurry image',
          'createdAt': '2026-08-16T08:05:00.000Z',
          'updatedAt': '2026-08-16T08:10:00.000Z',
        },
      };
      final payment = await api.getPayment('pay-9');
      expect(adapter.path, '/payments/pay-9');
      expect(adapter.method, 'GET');
      expect(payment.isRejected, isTrue);
      expect(payment.rejectionReason, 'Blurry image');
      expect(payment.reference, 'REF-1');
      expect(payment.hasReceipt, isTrue);
    });
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  String? method;
  String? path;
  Map<String, dynamic>? requestJson;
  Map<String, dynamic> headers = {};
  Map<String, dynamic> body = {'success': true, 'data': null};

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
    headers = Map<String, dynamic>.from(options.headers);
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
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}
