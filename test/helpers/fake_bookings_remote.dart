import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_api.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_models.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

class FakeBookingsRemote implements BookingsRemoteSource {
  FakeBookingsRemote({
    this.failWith,
    this.remainingFailures = 0,
    this.delay = Duration.zero,
    this.holdsUntil,
    this.booking,
  });

  Object? failWith;
  int remainingFailures;
  Duration delay;
  DateTime? holdsUntil;
  CustomerBooking? booking;
  final List<String> createdOccurrenceIds = [];
  final List<String?> idempotencyKeys = [];
  final List<String> getBookingIds = [];

  DateTime get _defaultHoldsUntil =>
      holdsUntil ?? DateTime.now().toUtc().add(const Duration(minutes: 15));

  @override
  Future<CreatedBooking> createBooking({
    required String slotOccurrenceId,
    String? idempotencyKey,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    idempotencyKeys.add(idempotencyKey);
    if (failWith != null && remainingFailures != 0) {
      if (remainingFailures > 0) remainingFailures--;
      throw failWith!;
    }
    createdOccurrenceIds.add(slotOccurrenceId);
    return CreatedBooking(
      id: 'b-${createdOccurrenceIds.length}',
      status: 'PENDING',
      date: '2026-08-14',
      startTime: '08:00',
      endTime: '09:00',
      priceSdg: 15000,
      slotOccurrenceId: slotOccurrenceId,
      stadiumId: 'st1',
      pitchId: 'p1',
      holdsUntil: _defaultHoldsUntil,
    );
  }

  @override
  Future<CustomerBooking> getBooking(String bookingId) async {
    getBookingIds.add(bookingId);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (failWith != null && remainingFailures != 0) {
      if (remainingFailures > 0) remainingFailures--;
      throw failWith!;
    }
    return booking ??
        CustomerBooking(
          id: bookingId,
          status: 'PENDING',
          date: '2026-08-14',
          startTime: '08:00',
          endTime: '09:00',
          priceSdg: 15000,
          currency: 'SDG',
          slotOccurrenceId: 'occ-1',
          pitchId: 'p1',
          stadiumId: 'st1',
          stadiumName: 'Al-Nile Stadium',
          pitchName: 'Pitch A',
          pitchType: PitchType.fiveASide,
          holdsUntil: _defaultHoldsUntil,
        );
  }
}
