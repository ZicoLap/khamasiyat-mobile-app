import 'package:khamasiyat_mobile_app/core/clock/stadium_time.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/slot_duration.dart';

/// One AVAILABLE slot occurrence from `GET /pitches/:id/availability`.
class AvailabilitySlot {
  const AvailabilitySlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.priceSdg,
    required this.currency,
    required this.status,
  });

  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final int priceSdg;
  final String currency;
  final String status;

  bool get isAvailable => status == 'AVAILABLE';

  int get startMinutes => StadiumTime.parseWallClockToMinutes(startTime);

  int get durationMinutes => SlotDuration.minutesBetween(startTime, endTime);

  SlotPeriod get period {
    if (startMinutes < 12 * 60) return SlotPeriod.morning;
    if (startMinutes < 17 * 60) return SlotPeriod.afternoon;
    return SlotPeriod.evening;
  }

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    final price = json['priceSdg'] ?? json['price'];
    return AvailabilitySlot(
      id: json['id'] as String,
      date: (json['date'] as String).substring(0, 10),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      priceSdg: (price as num).toInt(),
      currency: json['currency'] as String? ?? 'SDG',
      status: json['status'] as String? ?? 'AVAILABLE',
    );
  }
}

enum SlotPeriod { morning, afternoon, evening }

class PitchAvailability {
  const PitchAvailability({required this.currency, required this.items});

  final String currency;
  final List<AvailabilitySlot> items;

  List<AvailabilitySlot> forDate(String isoDate) {
    return items.where((s) => s.date == isoDate).toList(growable: false);
  }

  int? get minPriceSdg {
    if (items.isEmpty) return null;
    return items.map((s) => s.priceSdg).reduce((a, b) => a < b ? a : b);
  }

  int? minPriceForDate(String isoDate) {
    final day = forDate(isoDate);
    if (day.isEmpty) return null;
    return day.map((s) => s.priceSdg).reduce((a, b) => a < b ? a : b);
  }

  factory PitchAvailability.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? const [];
    return PitchAvailability(
      currency: json['currency'] as String? ?? 'SDG',
      items: raw
          .map(
            (e) =>
                AvailabilitySlot.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(growable: false),
    );
  }
}

class AvailabilityQuery {
  const AvailabilityQuery({
    required this.pitchId,
    required this.from,
    required this.to,
  });

  final String pitchId;
  final String from;
  final String to;

  @override
  bool operator ==(Object other) {
    return other is AvailabilityQuery &&
        other.pitchId == pitchId &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => Object.hash(pitchId, from, to);
}
