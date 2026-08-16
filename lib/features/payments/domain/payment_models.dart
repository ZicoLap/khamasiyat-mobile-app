/// Backend `PaymentMethod` enum values.
enum StadiumPaymentMethodType {
  cash('CASH'),
  bankak('BANKAK'),
  bankTransfer('BANK_TRANSFER');

  const StadiumPaymentMethodType(this.apiValue);
  final String apiValue;

  bool get requiresReceipt =>
      this == StadiumPaymentMethodType.bankak ||
      this == StadiumPaymentMethodType.bankTransfer;

  static StadiumPaymentMethodType fromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'CASH':
        return StadiumPaymentMethodType.cash;
      case 'BANKAK':
        return StadiumPaymentMethodType.bankak;
      case 'BANK_TRANSFER':
        return StadiumPaymentMethodType.bankTransfer;
      default:
        throw FormatException('Unknown payment method: $raw');
    }
  }
}

/// Enabled stadium payment method from `GET /stadiums/:id/payment-methods`.
class StadiumPaymentMethod {
  const StadiumPaymentMethod({
    required this.method,
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.iban,
    this.phoneNumber,
    this.instructions,
  });

  final StadiumPaymentMethodType method;
  final String? bankName;
  final String? accountName;
  final String? accountNumber;
  final String? iban;
  final String? phoneNumber;
  final String? instructions;

  factory StadiumPaymentMethod.fromJson(Map<String, dynamic> json) {
    return StadiumPaymentMethod(
      method: StadiumPaymentMethodType.fromApi(json['method'] as String),
      bankName: json['bankName'] as String?,
      accountName: json['accountName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      iban: json['iban'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      instructions: json['instructions'] as String?,
    );
  }
}

/// Public payment from submit / GET payment endpoints.
class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.bookingId,
    required this.stadiumId,
    required this.method,
    required this.status,
    required this.amountSdg,
    required this.currency,
    required this.hasReceipt,
    this.reference,
    this.rejectionReason,
    this.submittedAt,
    this.confirmedAt,
    this.rejectedAt,
  });

  final String id;
  final String bookingId;
  final String stadiumId;
  final StadiumPaymentMethodType method;
  final String status;
  final int amountSdg;
  final String currency;
  final bool hasReceipt;
  final String? reference;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? confirmedAt;
  final DateTime? rejectedAt;

  bool get isSubmitted => status == 'SUBMITTED';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isRejected => status == 'REJECTED';

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      stadiumId: json['stadiumId'] as String,
      method: StadiumPaymentMethodType.fromApi(json['method'] as String),
      status: json['status'] as String,
      amountSdg: (json['amountSdg'] as num).toInt(),
      currency: json['currency'] as String? ?? 'SDG',
      hasReceipt: json['hasReceipt'] as bool? ?? false,
      reference: json['reference'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      submittedAt: _parseInstant(json['submittedAt']),
      confirmedAt: _parseInstant(json['confirmedAt']),
      rejectedAt: _parseInstant(json['rejectedAt']),
    );
  }

  static DateTime? _parseInstant(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }
}

class ReceiptUploadIntent {
  const ReceiptUploadIntent({
    required this.uploadIntentId,
    required this.uploadUrl,
    required this.expiresAt,
    required this.headers,
    required this.maxBytes,
  });

  final String uploadIntentId;
  final String uploadUrl;
  final DateTime expiresAt;
  final Map<String, String> headers;
  final int maxBytes;

  factory ReceiptUploadIntent.fromJson(Map<String, dynamic> json) {
    final headersRaw = json['headers'];
    final headers = <String, String>{};
    if (headersRaw is Map) {
      headersRaw.forEach((key, value) {
        if (value != null) headers['$key'] = '$value';
      });
    }
    return ReceiptUploadIntent(
      uploadIntentId: json['uploadIntentId'] as String,
      uploadUrl: json['uploadUrl'] as String,
      expiresAt:
          DateTime.tryParse(json['expiresAt'] as String? ?? '')?.toUtc() ??
          DateTime.now().toUtc().add(const Duration(minutes: 10)),
      headers: headers,
      maxBytes: (json['maxBytes'] as num?)?.toInt() ?? 5 * 1024 * 1024,
    );
  }
}

class SelectedReceiptFile {
  const SelectedReceiptFile({
    required this.name,
    required this.bytes,
    required this.contentType,
  });

  final String name;
  final List<int> bytes;
  final String contentType;

  int get sizeBytes => bytes.length;
}

/// Allowed receipt MIME types (backend MVP).
const kReceiptAllowedContentTypes = <String>{
  'image/jpeg',
  'image/png',
  'image/webp',
  'application/pdf',
};

const kReceiptDefaultMaxBytes = 5 * 1024 * 1024;
