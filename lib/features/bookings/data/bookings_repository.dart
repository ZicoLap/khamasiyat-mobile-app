import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_api.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_models.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';

class BookingsRepository {
  BookingsRepository(this._remote);

  final BookingsRemoteSource _remote;

  Future<CreatedBooking> createBooking({
    required String slotOccurrenceId,
    required String idempotencyKey,
  }) {
    return _remote.createBooking(
      slotOccurrenceId: slotOccurrenceId,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<CustomerBooking> getBooking(String bookingId) {
    return _remote.getBooking(bookingId);
  }
}

final bookingsApiProvider = Provider<BookingsApi>((ref) {
  return BookingsApi(ref.watch(apiClientProvider));
});

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  return BookingsRepository(ref.watch(bookingsApiProvider));
});
