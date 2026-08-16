import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/payments/domain/payment_models.dart';

abstract class PaymentsRemoteSource {
  Future<List<StadiumPaymentMethod>> listStadiumPaymentMethods(
    String stadiumId,
  );

  Future<ReceiptUploadIntent> createReceiptUploadIntent({
    required String bookingId,
    required String method,
    required String contentType,
    required int sizeBytes,
  });

  Future<PaymentRecord> submitPayment({
    required String bookingId,
    required String method,
    String? reference,
    String? receiptUploadIntentId,
    String? idempotencyKey,
  });

  Future<List<PaymentRecord>> listBookingPayments(String bookingId);

  Future<PaymentRecord> getPayment(String paymentId);
}

class PaymentsApi implements PaymentsRemoteSource {
  PaymentsApi(this._client);

  final ApiClient _client;

  @override
  Future<List<StadiumPaymentMethod>> listStadiumPaymentMethods(
    String stadiumId,
  ) {
    return _client.get(
      '/stadiums/$stadiumId/payment-methods',
      fromJson: (json) {
        final list = json as List<dynamic>? ?? const [];
        return list
            .map(
              (e) => StadiumPaymentMethod.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(growable: false);
      },
    );
  }

  @override
  Future<ReceiptUploadIntent> createReceiptUploadIntent({
    required String bookingId,
    required String method,
    required String contentType,
    required int sizeBytes,
  }) {
    return _client.post(
      '/customer/payments/receipt-uploads',
      data: {
        'bookingId': bookingId,
        'method': method,
        'contentType': contentType,
        'sizeBytes': sizeBytes,
      },
      fromJson:
          (json) => ReceiptUploadIntent.fromJson(
            Map<String, dynamic>.from(json! as Map),
          ),
    );
  }

  @override
  Future<PaymentRecord> submitPayment({
    required String bookingId,
    required String method,
    String? reference,
    String? receiptUploadIntentId,
    String? idempotencyKey,
  }) {
    final body = <String, dynamic>{'method': method};
    if (reference != null && reference.trim().isNotEmpty) {
      body['reference'] = reference.trim();
    }
    if (receiptUploadIntentId != null) {
      body['receiptUploadIntentId'] = receiptUploadIntentId;
    }
    return _client.post(
      '/bookings/$bookingId/payments',
      data: body,
      options:
          idempotencyKey == null
              ? null
              : Options(headers: {'Idempotency-Key': idempotencyKey}),
      fromJson:
          (json) =>
              PaymentRecord.fromJson(Map<String, dynamic>.from(json! as Map)),
    );
  }

  @override
  Future<List<PaymentRecord>> listBookingPayments(String bookingId) {
    return _client.get(
      '/bookings/$bookingId/payments',
      fromJson: (json) {
        final list = json as List<dynamic>? ?? const [];
        return list
            .map(
              (e) =>
                  PaymentRecord.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList(growable: false);
      },
    );
  }

  @override
  Future<PaymentRecord> getPayment(String paymentId) {
    return _client.get(
      '/payments/$paymentId',
      fromJson:
          (json) =>
              PaymentRecord.fromJson(Map<String, dynamic>.from(json! as Map)),
    );
  }
}

/// Direct PUT to a backend-issued upload URL (no API Bearer token).
class ReceiptUploadClient {
  ReceiptUploadClient([Dio? dio]) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<void> putReceipt({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
    void Function(int sent, int total)? onProgress,
  }) async {
    await _dio.put<void>(
      uploadUrl,
      data: bytes,
      options: Options(
        headers: {
          'Content-Type': contentType,
          'Content-Length': bytes.length,
        },
        contentType: contentType,
        responseType: ResponseType.bytes,
        validateStatus: (code) => code != null && code >= 200 && code < 300,
      ),
      onSendProgress: onProgress,
    );
  }
}

class PaymentsRepository {
  PaymentsRepository(this._remote, this._uploadClient);

  final PaymentsRemoteSource _remote;
  final ReceiptUploadClient _uploadClient;

  Future<List<StadiumPaymentMethod>> listStadiumPaymentMethods(
    String stadiumId,
  ) {
    return _remote.listStadiumPaymentMethods(stadiumId);
  }

  Future<ReceiptUploadIntent> createReceiptUploadIntent({
    required String bookingId,
    required String method,
    required String contentType,
    required int sizeBytes,
  }) {
    return _remote.createReceiptUploadIntent(
      bookingId: bookingId,
      method: method,
      contentType: contentType,
      sizeBytes: sizeBytes,
    );
  }

  Future<void> uploadReceiptBytes({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
    void Function(int sent, int total)? onProgress,
  }) {
    return _uploadClient.putReceipt(
      uploadUrl: uploadUrl,
      bytes: bytes,
      contentType: contentType,
      onProgress: onProgress,
    );
  }

  Future<PaymentRecord> submitPayment({
    required String bookingId,
    required String method,
    String? reference,
    String? receiptUploadIntentId,
    required String idempotencyKey,
  }) {
    return _remote.submitPayment(
      bookingId: bookingId,
      method: method,
      reference: reference,
      receiptUploadIntentId: receiptUploadIntentId,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<List<PaymentRecord>> listBookingPayments(String bookingId) {
    return _remote.listBookingPayments(bookingId);
  }

  Future<PaymentRecord> getPayment(String paymentId) {
    return _remote.getPayment(paymentId);
  }
}

final paymentsApiProvider = Provider<PaymentsApi>((ref) {
  return PaymentsApi(ref.watch(apiClientProvider));
});

final receiptUploadClientProvider = Provider<ReceiptUploadClient>((ref) {
  return ReceiptUploadClient();
});

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(
    ref.watch(paymentsApiProvider),
    ref.watch(receiptUploadClientProvider),
  );
});
