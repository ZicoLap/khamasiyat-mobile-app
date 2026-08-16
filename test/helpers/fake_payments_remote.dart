import 'package:khamasiyat_mobile_app/features/payments/data/payments_repository.dart';
import 'package:khamasiyat_mobile_app/features/payments/domain/payment_models.dart';

class FakePaymentsRemote implements PaymentsRemoteSource {
  FakePaymentsRemote({
    List<StadiumPaymentMethod>? methods,
    this.intent,
    this.submitResult,
    this.getPaymentResult,
    this.listPayments = const [],
    this.failIntentWith,
    this.failSubmitWith,
    this.failGetWith,
    this.failMethodsWith,
  }) : methods = methods ?? _defaultMethods;

  static final _defaultMethods = [
    const StadiumPaymentMethod(
      method: StadiumPaymentMethodType.cash,
      instructions: 'Pay at the gate',
    ),
    const StadiumPaymentMethod(
      method: StadiumPaymentMethodType.bankak,
      accountName: 'Stadium Ops',
      accountNumber: '123456',
      bankName: 'Bank of Khartoum',
      instructions: 'Use booking id as note',
    ),
    const StadiumPaymentMethod(
      method: StadiumPaymentMethodType.bankTransfer,
      accountName: 'Stadium Ops',
      accountNumber: '987654',
      bankName: 'Faisal Islamic Bank',
    ),
  ];

  List<StadiumPaymentMethod> methods;
  ReceiptUploadIntent? intent;
  PaymentRecord? submitResult;
  PaymentRecord? getPaymentResult;
  List<PaymentRecord> listPayments;
  Object? failIntentWith;
  Object? failSubmitWith;
  Object? failGetWith;
  Object? failMethodsWith;

  final List<Map<String, dynamic>> intentRequests = [];
  final List<Map<String, dynamic>> submitRequests = [];
  final List<String> stadiumIds = [];
  int getPaymentCalls = 0;

  @override
  Future<List<StadiumPaymentMethod>> listStadiumPaymentMethods(
    String stadiumId,
  ) async {
    stadiumIds.add(stadiumId);
    if (failMethodsWith != null) throw failMethodsWith!;
    return List.unmodifiable(methods);
  }

  @override
  Future<ReceiptUploadIntent> createReceiptUploadIntent({
    required String bookingId,
    required String method,
    required String contentType,
    required int sizeBytes,
  }) async {
    intentRequests.add({
      'bookingId': bookingId,
      'method': method,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
    });
    if (failIntentWith != null) throw failIntentWith!;
    return intent ??
        ReceiptUploadIntent(
          uploadIntentId: 'intent-1',
          uploadUrl: 'https://upload.example/receipt',
          expiresAt: DateTime.utc(2099, 1, 1),
          headers: const {'Content-Type': 'image/jpeg'},
          maxBytes: kReceiptDefaultMaxBytes,
        );
  }

  @override
  Future<PaymentRecord> submitPayment({
    required String bookingId,
    required String method,
    String? reference,
    String? receiptUploadIntentId,
    String? idempotencyKey,
  }) async {
    submitRequests.add({
      'bookingId': bookingId,
      'method': method,
      'reference': reference,
      'receiptUploadIntentId': receiptUploadIntentId,
      'idempotencyKey': idempotencyKey,
    });
    if (failSubmitWith != null) throw failSubmitWith!;
    return submitResult ??
        PaymentRecord(
          id: 'pay-1',
          bookingId: bookingId,
          stadiumId: 'st1',
          method: StadiumPaymentMethodType.fromApi(method),
          status: 'SUBMITTED',
          amountSdg: 15000,
          currency: 'SDG',
          hasReceipt: receiptUploadIntentId != null,
          reference: reference,
          submittedAt: DateTime.utc(2026, 8, 14, 8, 5),
        );
  }

  @override
  Future<List<PaymentRecord>> listBookingPayments(String bookingId) async {
    return listPayments;
  }

  @override
  Future<PaymentRecord> getPayment(String paymentId) async {
    getPaymentCalls++;
    if (failGetWith != null) throw failGetWith!;
    return getPaymentResult ??
        PaymentRecord(
          id: paymentId,
          bookingId: 'b-1',
          stadiumId: 'st1',
          method: StadiumPaymentMethodType.cash,
          status: 'SUBMITTED',
          amountSdg: 15000,
          currency: 'SDG',
          hasReceipt: false,
        );
  }
}

class FakeReceiptUploadClient extends ReceiptUploadClient {
  FakeReceiptUploadClient({this.failWith});

  Object? failWith;
  int putCalls = 0;
  final List<Map<String, dynamic>> puts = [];

  @override
  Future<void> putReceipt({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
    void Function(int sent, int total)? onProgress,
  }) async {
    putCalls++;
    puts.add({
      'uploadUrl': uploadUrl,
      'bytesLength': bytes.length,
      'contentType': contentType,
    });
    if (failWith != null) throw failWith!;
    onProgress?.call(bytes.length, bytes.length);
  }
}
