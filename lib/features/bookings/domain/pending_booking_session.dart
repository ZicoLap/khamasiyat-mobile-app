import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_models.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_review_draft.dart';

/// Real PENDING booking plus review display context for Payment handoff.
class PendingBookingSession {
  const PendingBookingSession({
    required this.booking,
    required this.review,
  });

  final CreatedBooking booking;
  final BookingReviewDraft review;
}
