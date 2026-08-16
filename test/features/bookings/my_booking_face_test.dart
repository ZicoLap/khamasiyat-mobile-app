import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/my_booking_face.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

CustomerBooking _booking({
  String status = 'PENDING',
  DateTime? holdsUntil,
  CustomerPaymentSummary? paymentSummary,
  bool hasAccessPin = false,
}) {
  return CustomerBooking(
    id: 'b-1',
    status: status,
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
    hasAccessPin: hasAccessPin,
    holdsUntil: holdsUntil,
    paymentSummary: paymentSummary,
  );
}

void main() {
  final now = DateTime.utc(2026, 8, 14, 8);
  final hold = DateTime.utc(2026, 8, 14, 8, 12);

  test('PENDING + no payment → payment required + complete payment', () {
    withClock(Clock.fixed(now), () {
      final booking = _booking(holdsUntil: hold);
      expect(mapMyBookingFace(booking), MyBookingFace.paymentRequired);
      expect(myBookingActionFor(booking), MyBookingAction.completePayment);
      expect(
        bookingDetailPaymentAction(booking),
        MyBookingAction.completePayment,
      );
      expect(myBookingShowsHoldCountdown(booking), isTrue);
      expect(myBookingRemainingHold(booking), const Duration(minutes: 12));
    });
  });

  test('hold remaining uses holdsUntil and does not reset', () {
    final until = DateTime.utc(2026, 8, 14, 8, 15);
    withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 8, 0)), () {
      expect(
        myBookingRemainingHold(_booking(holdsUntil: until)),
        const Duration(minutes: 15),
      );
    });
    withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 8, 5)), () {
      expect(
        myBookingRemainingHold(_booking(holdsUntil: until)),
        const Duration(minutes: 10),
      );
    });
  });

  test('PENDING + SUBMITTED → waiting, view payment, no complete', () {
    final booking = _booking(
      holdsUntil: hold,
      paymentSummary: const CustomerPaymentSummary(
        id: 'pay-1',
        status: 'SUBMITTED',
        method: 'CASH',
        amountSdg: 15000,
        currency: 'SDG',
        hasReceipt: false,
      ),
    );
    withClock(Clock.fixed(now), () {
      expect(mapMyBookingFace(booking), MyBookingFace.waitingConfirmation);
      expect(myBookingActionFor(booking), MyBookingAction.viewPayment);
      expect(bookingDetailPaymentAction(booking), MyBookingAction.viewPayment);
      expect(myBookingShowsHoldCountdown(booking), isFalse);
      expect(bookingDetailShowsPaymentBanner(booking), isTrue);
    });
  });

  test('PENDING + REJECTED + valid hold → retry payment', () {
    final booking = _booking(
      holdsUntil: hold,
      paymentSummary: const CustomerPaymentSummary(
        id: 'pay-9',
        status: 'REJECTED',
        method: 'BANKAK',
        amountSdg: 15000,
        currency: 'SDG',
        hasReceipt: true,
        rejectionReason: 'Blurry image',
      ),
    );
    withClock(Clock.fixed(now), () {
      expect(mapMyBookingFace(booking), MyBookingFace.paymentRejected);
      expect(myBookingActionFor(booking), MyBookingAction.retryPayment);
      expect(bookingDetailPaymentAction(booking), MyBookingAction.retryPayment);
    });
  });

  test('CONFIRMED → no list CTA; card opens detail', () {
    final booking = _booking(status: 'CONFIRMED');
    expect(mapMyBookingFace(booking), MyBookingFace.confirmed);
    expect(myBookingActionFor(booking), MyBookingAction.none);
    expect(bookingDetailPaymentAction(booking), MyBookingAction.none);
    expect(bookingDetailShowsPaymentBanner(booking), isFalse);
    expect(myBookingIsUpcoming(booking), isTrue);
  });

  test('PIN is offered only for CONFIRMED bookings with hasAccessPin', () {
    expect(
      bookingDetailOffersPin(_booking(status: 'CONFIRMED', hasAccessPin: true)),
      isTrue,
    );
    expect(
      bookingDetailOffersPin(
        _booking(status: 'CONFIRMED', hasAccessPin: false),
      ),
      isFalse,
    );
    expect(
      bookingDetailOffersPin(_booking(status: 'COMPLETED', hasAccessPin: true)),
      isFalse,
    );
    expect(
      bookingDetailOffersPin(_booking(status: 'CANCELLED', hasAccessPin: true)),
      isFalse,
    );
    expect(
      bookingDetailOffersPin(_booking(status: 'EXPIRED', hasAccessPin: true)),
      isFalse,
    );
    expect(
      bookingDetailOffersPin(_booking(status: 'PENDING', hasAccessPin: true)),
      isFalse,
    );
  });

  test('upcoming vs past follows booking status', () {
    expect(myBookingIsUpcoming(_booking(status: 'PENDING')), isTrue);
    expect(myBookingIsUpcoming(_booking(status: 'CONFIRMED')), isTrue);
    expect(myBookingIsUpcoming(_booking(status: 'COMPLETED')), isFalse);
    expect(myBookingIsUpcoming(_booking(status: 'CANCELLED')), isFalse);
    expect(myBookingIsUpcoming(_booking(status: 'EXPIRED')), isFalse);
  });

  test('CANCELLED COMPLETED EXPIRED have no payment action', () {
    expect(
      mapMyBookingFace(_booking(status: 'CANCELLED')),
      MyBookingFace.cancelled,
    );
    expect(
      myBookingActionFor(_booking(status: 'CANCELLED')),
      MyBookingAction.none,
    );
    expect(
      bookingDetailPaymentAction(_booking(status: 'CANCELLED')),
      MyBookingAction.none,
    );
    expect(
      mapMyBookingFace(_booking(status: 'COMPLETED')),
      MyBookingFace.completed,
    );
    expect(
      myBookingActionFor(_booking(status: 'COMPLETED')),
      MyBookingAction.none,
    );
    expect(
      bookingDetailPaymentAction(_booking(status: 'COMPLETED')),
      MyBookingAction.none,
    );
    expect(
      mapMyBookingFace(_booking(status: 'EXPIRED')),
      MyBookingFace.expired,
    );
    expect(
      myBookingActionFor(_booking(status: 'EXPIRED')),
      MyBookingAction.none,
    );
    expect(
      bookingDetailPaymentAction(_booking(status: 'EXPIRED')),
      MyBookingAction.none,
    );
  });

  test('expired hold disables complete payment without flipping status', () {
    withClock(Clock.fixed(now), () {
      final booking = _booking(holdsUntil: DateTime.utc(2026, 8, 14, 7, 50));
      expect(mapMyBookingFace(booking), MyBookingFace.paymentRequired);
      expect(myBookingActionFor(booking), MyBookingAction.none);
    });
  });
}
