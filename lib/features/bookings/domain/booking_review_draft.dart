import 'package:khamasiyat_mobile_app/features/availability/domain/availability_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/pitch_detail_models.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

/// Display + commit identity for Booking Summary.
///
/// [slotOccurrenceId] is the only value used for `POST /bookings`.
/// Other fields are presentation-only from already-loaded catalog/availability.
class BookingReviewDraft {
  const BookingReviewDraft({
    required this.pitchId,
    required this.slotOccurrenceId,
    required this.stadiumId,
    required this.stadiumName,
    required this.stadiumState,
    required this.stadiumCity,
    required this.pitchName,
    required this.pitchType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.priceSdg,
    required this.currency,
    this.lengthMeters,
    this.widthMeters,
    this.photoUrl,
  });

  final String pitchId;
  final String slotOccurrenceId;
  final String stadiumId;
  final String stadiumName;
  final SudanState stadiumState;
  final SudanCity stadiumCity;
  final String pitchName;
  final PitchType pitchType;
  final double? lengthMeters;
  final double? widthMeters;
  final String? photoUrl;
  final String date;
  final String startTime;
  final String endTime;
  final int priceSdg;
  final String currency;

  factory BookingReviewDraft.fromPitchAndSlot({
    required PitchDetail pitch,
    required AvailabilitySlot slot,
  }) {
    final photo =
        pitch.photos.isEmpty
            ? null
            : pitch.photos.firstWhere(
              (p) => p.isPrimary,
              orElse: () => pitch.photos.first,
            );
    return BookingReviewDraft(
      pitchId: pitch.id,
      slotOccurrenceId: slot.id,
      stadiumId: pitch.stadium.id,
      stadiumName: pitch.stadium.name,
      stadiumState: pitch.stadium.state,
      stadiumCity: pitch.stadium.city,
      pitchName: pitch.name,
      pitchType: pitch.type,
      lengthMeters: pitch.lengthMeters,
      widthMeters: pitch.widthMeters,
      photoUrl: photo?.url,
      date: slot.date,
      startTime: slot.startTime,
      endTime: slot.endTime,
      priceSdg: slot.priceSdg,
      currency: slot.currency,
    );
  }
}
