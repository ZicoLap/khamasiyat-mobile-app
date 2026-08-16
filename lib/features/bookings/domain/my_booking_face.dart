import 'package:clock/clock.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';

/// Customer-facing booking state. Booking status and payment status stay
/// separate; this is only the mapped label/action for My Bookings cards.
enum MyBookingFace {
  paymentRequired,
  waitingConfirmation,
  paymentRejected,
  confirmed,
  cancelled,
  completed,
  expired,
}

enum MyBookingAction {
  completePayment,
  retryPayment,
  viewPayment,
  viewBooking,
  none,
}

enum MyBookingsFilter { all, pending, confirmed, completed }

extension MyBookingsFilterApi on MyBookingsFilter {
  /// Backend `BookingStatus` query value, or `null` for unfiltered list.
  String? get apiStatus {
    switch (this) {
      case MyBookingsFilter.all:
        return null;
      case MyBookingsFilter.pending:
        return 'PENDING';
      case MyBookingsFilter.confirmed:
        return 'CONFIRMED';
      case MyBookingsFilter.completed:
        return 'COMPLETED';
    }
  }
}

MyBookingFace mapMyBookingFace(CustomerBooking booking) {
  if (booking.isCancelled) return MyBookingFace.cancelled;
  if (booking.isCompleted) return MyBookingFace.completed;
  if (booking.isExpired) return MyBookingFace.expired;
  if (booking.isConfirmed) return MyBookingFace.confirmed;

  final paymentStatus = booking.paymentSummary?.status;
  if (paymentStatus == 'SUBMITTED') {
    return MyBookingFace.waitingConfirmation;
  }
  if (paymentStatus == 'REJECTED') {
    return MyBookingFace.paymentRejected;
  }
  if (paymentStatus == 'CONFIRMED') {
    return MyBookingFace.waitingConfirmation;
  }
  return MyBookingFace.paymentRequired;
}

MyBookingAction myBookingActionFor(CustomerBooking booking, {DateTime? now}) {
  final moment = (now ?? clock.now()).toUtc();
  switch (mapMyBookingFace(booking)) {
    case MyBookingFace.paymentRequired:
      if (booking.isPending &&
          booking.holdsUntil != null &&
          !booking.isHoldExpired(now: moment)) {
        return MyBookingAction.completePayment;
      }
      return MyBookingAction.none;
    case MyBookingFace.waitingConfirmation:
      return MyBookingAction.viewPayment;
    case MyBookingFace.paymentRejected:
      if (booking.isPending &&
          booking.holdsUntil != null &&
          !booking.isHoldExpired(now: moment)) {
        return MyBookingAction.retryPayment;
      }
      return MyBookingAction.none;
    case MyBookingFace.confirmed:
      return MyBookingAction.none;
    case MyBookingFace.cancelled:
    case MyBookingFace.completed:
    case MyBookingFace.expired:
      return MyBookingAction.none;
  }
}

/// Booking Detail payment CTA. Confirmed bookings are already on this screen.
MyBookingAction bookingDetailPaymentAction(
  CustomerBooking booking, {
  DateTime? now,
}) {
  final action = myBookingActionFor(booking, now: now);
  if (action == MyBookingAction.viewBooking) {
    return MyBookingAction.none;
  }
  return action;
}

/// PIN is only offered when the backend says one exists and the booking
/// is still CONFIRMED (the access-pin endpoint rejects other statuses).
bool bookingDetailOffersPin(CustomerBooking booking) {
  return booking.isConfirmed && booking.hasAccessPin;
}

/// Pending and confirmed bookings are still “this game”; the rest are history.
bool myBookingIsUpcoming(CustomerBooking booking) {
  return booking.isPending || booking.isConfirmed;
}

/// Compact payment note on Detail — not a second status headline.
bool bookingDetailShowsPaymentBanner(CustomerBooking booking, {DateTime? now}) {
  switch (mapMyBookingFace(booking)) {
    case MyBookingFace.paymentRequired:
      return myBookingShowsHoldCountdown(booking, now: now);
    case MyBookingFace.waitingConfirmation:
    case MyBookingFace.paymentRejected:
      return true;
    case MyBookingFace.confirmed:
    case MyBookingFace.cancelled:
    case MyBookingFace.completed:
    case MyBookingFace.expired:
      return false;
  }
}

bool myBookingShowsHoldCountdown(CustomerBooking booking, {DateTime? now}) {
  final moment = (now ?? clock.now()).toUtc();
  if (mapMyBookingFace(booking) != MyBookingFace.paymentRequired) {
    return false;
  }
  if (booking.holdsUntil == null) return false;
  return !booking.isHoldExpired(now: moment);
}

Duration? myBookingRemainingHold(CustomerBooking booking, {DateTime? now}) {
  final until = booking.holdsUntil;
  if (until == null) return null;
  final left = until.difference((now ?? clock.now()).toUtc());
  if (left.isNegative) return Duration.zero;
  return left;
}
