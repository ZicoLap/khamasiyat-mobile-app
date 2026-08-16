/// Customer booking projection returned by `POST /bookings`.
class CreatedBooking {
  const CreatedBooking({
    required this.id,
    required this.status,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.priceSdg,
    required this.slotOccurrenceId,
    this.stadiumId,
    this.pitchId,
    this.currency = 'SDG',
    this.holdsUntil,
  });

  final String id;
  final String status;
  final String date;
  final String startTime;
  final String endTime;
  final int priceSdg;
  final String slotOccurrenceId;
  final String? stadiumId;
  final String? pitchId;
  final String currency;

  /// Backend hold expiry (UTC). Present when status is PENDING.
  final DateTime? holdsUntil;

  factory CreatedBooking.fromJson(Map<String, dynamic> json) {
    return CreatedBooking(
      id: json['id'] as String,
      status: json['status'] as String,
      date: (json['date'] as String).substring(0, 10),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      priceSdg: (json['priceSdg'] as num).toInt(),
      slotOccurrenceId: json['slotOccurrenceId'] as String,
      stadiumId: json['stadiumId'] as String?,
      pitchId: json['pitchId'] as String?,
      currency: json['currency'] as String? ?? 'SDG',
      holdsUntil: _parseHoldsUntil(json['holdsUntil']),
    );
  }

  static DateTime? _parseHoldsUntil(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }
}
