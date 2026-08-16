import 'package:dio/dio.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_models.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';

abstract class BookingsRemoteSource {
  Future<CreatedBooking> createBooking({
    required String slotOccurrenceId,
    String? idempotencyKey,
  });

  Future<CustomerBooking> getBooking(String bookingId);
}

class BookingsApi implements BookingsRemoteSource {
  BookingsApi(this._client);

  final ApiClient _client;

  @override
  Future<CreatedBooking> createBooking({
    required String slotOccurrenceId,
    String? idempotencyKey,
  }) {
    return _client.post(
      '/bookings',
      data: {'slotOccurrenceId': slotOccurrenceId},
      options:
          idempotencyKey == null
              ? null
              : Options(headers: {'Idempotency-Key': idempotencyKey}),
      fromJson:
          (json) =>
              CreatedBooking.fromJson(Map<String, dynamic>.from(json! as Map)),
    );
  }

  @override
  Future<CustomerBooking> getBooking(String bookingId) {
    return _client.get(
      '/bookings/$bookingId',
      fromJson:
          (json) =>
              CustomerBooking.fromJson(Map<String, dynamic>.from(json! as Map)),
    );
  }
}
