import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_review_draft.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/pending_booking_session.dart';

/// Active Booking Summary draft. Cleared after commit or when abandoned.
final bookingReviewDraftProvider = StateProvider<BookingReviewDraft?>(
  (ref) => null,
);

/// Last successful PENDING booking waiting for payment.
final pendingBookingSessionProvider = StateProvider<PendingBookingSession?>(
  (ref) => null,
);
