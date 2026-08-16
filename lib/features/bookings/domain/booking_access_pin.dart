/// Customer access PIN from `GET /bookings/:bookingId/access-pin`.
///
/// The PIN is session-only. Do not persist or log the value.
class BookingAccessPin {
  const BookingAccessPin({required this.bookingId, required this.pin});

  final String bookingId;
  final String pin;

  factory BookingAccessPin.fromJson(Map<String, dynamic> json) {
    return BookingAccessPin(
      bookingId: json['bookingId'] as String,
      pin: json['pin'] as String,
    );
  }

  @override
  String toString() => 'BookingAccessPin(bookingId: $bookingId, pin: ***)';
}
