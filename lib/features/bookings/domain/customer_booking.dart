import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

/// Customer booking from `GET /bookings/:id` (and rich create responses).
class CustomerBooking {
  const CustomerBooking({
    required this.id,
    required this.status,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.priceSdg,
    required this.currency,
    required this.slotOccurrenceId,
    required this.pitchId,
    required this.stadiumId,
    required this.stadiumName,
    required this.pitchName,
    required this.pitchType,
    this.holdsUntil,
    this.paymentSummary,
  });

  final String id;
  final String status;
  final String date;
  final String startTime;
  final String endTime;
  final int priceSdg;
  final String currency;
  final String slotOccurrenceId;
  final String pitchId;
  final String stadiumId;
  final String stadiumName;
  final String pitchName;
  final PitchType pitchType;
  final DateTime? holdsUntil;
  final CustomerPaymentSummary? paymentSummary;

  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isExpired => status == 'EXPIRED';
  bool get isCancelled => status == 'CANCELLED';

  bool isHoldExpired({DateTime? now}) {
    final until = holdsUntil;
    if (until == null) return false;
    return until.isBefore((now ?? DateTime.now()).toUtc());
  }

  factory CustomerBooking.fromJson(Map<String, dynamic> json) {
    final stadium = Map<String, dynamic>.from(json['stadium'] as Map? ?? {});
    final pitch = Map<String, dynamic>.from(json['pitch'] as Map? ?? {});
    final summaryRaw = json['paymentSummary'];
    return CustomerBooking(
      id: json['id'] as String,
      status: json['status'] as String,
      date: (json['date'] as String).substring(0, 10),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      priceSdg: (json['priceSdg'] as num).toInt(),
      currency: json['currency'] as String? ?? 'SDG',
      slotOccurrenceId: json['slotOccurrenceId'] as String,
      pitchId: json['pitchId'] as String? ?? pitch['id'] as String? ?? '',
      stadiumId: json['stadiumId'] as String? ?? stadium['id'] as String? ?? '',
      stadiumName: stadium['name'] as String? ?? '',
      pitchName: pitch['name'] as String? ?? '',
      pitchType: PitchType.fromApi(
        pitch['type'] as String? ?? 'OTHER',
      ),
      holdsUntil: _parseInstant(json['holdsUntil']),
      paymentSummary:
          summaryRaw is Map
              ? CustomerPaymentSummary.fromJson(
                Map<String, dynamic>.from(summaryRaw),
              )
              : null,
    );
  }

  static DateTime? _parseInstant(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }
}

class CustomerPaymentSummary {
  const CustomerPaymentSummary({
    required this.id,
    required this.status,
    required this.method,
    required this.amountSdg,
    required this.currency,
    required this.hasReceipt,
    this.rejectionReason,
    this.submittedAt,
    this.confirmedAt,
    this.rejectedAt,
  });

  final String id;
  final String status;
  final String method;
  final int amountSdg;
  final String currency;
  final bool hasReceipt;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? confirmedAt;
  final DateTime? rejectedAt;

  factory CustomerPaymentSummary.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentSummary(
      id: json['id'] as String,
      status: json['status'] as String,
      method: json['method'] as String,
      amountSdg: (json['amountSdg'] as num).toInt(),
      currency: json['currency'] as String? ?? 'SDG',
      hasReceipt: json['hasReceipt'] as bool? ?? false,
      rejectionReason: json['rejectionReason'] as String?,
      submittedAt: CustomerBooking._parseInstant(json['submittedAt']),
      confirmedAt: CustomerBooking._parseInstant(json['confirmedAt']),
      rejectedAt: CustomerBooking._parseInstant(json['rejectedAt']),
    );
  }
}
