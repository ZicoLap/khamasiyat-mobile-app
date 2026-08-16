import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_api.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_access_pin.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_list_page.dart';
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
    this.listItems = const [],
    this.listTotal,
    this.failListWith,
    this.accessPin = '842157',
    this.failAccessPinWith,
  });

  Object? failWith;
  Object? failCancelWith;
  Object? failListWith;
  int remainingFailures;
  Duration delay;
  DateTime? holdsUntil;
  CustomerBooking? booking;
  List<CustomerBooking> listItems;
  int? listTotal;
  String? accessPin;
  Object? failAccessPinWith;
  final List<String> createdOccurrenceIds = [];
  final List<String?> idempotencyKeys = [];
  final List<String> getBookingIds = [];
  final List<String> cancelledIds = [];
  final List<Map<String, dynamic>> listRequests = [];
  final List<String> accessPinRequests = [];

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

  @override
  Future<CustomerBooking> cancelBooking(String bookingId) async {
    cancelledIds.add(bookingId);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (failCancelWith != null) throw failCancelWith!;
    final current = booking;
    return CustomerBooking(
      id: current?.id ?? bookingId,
      status: 'CANCELLED',
      date: current?.date ?? '2026-08-14',
      startTime: current?.startTime ?? '08:00',
      endTime: current?.endTime ?? '09:00',
      priceSdg: current?.priceSdg ?? 15000,
      currency: current?.currency ?? 'SDG',
      slotOccurrenceId: current?.slotOccurrenceId ?? 'occ-1',
      pitchId: current?.pitchId ?? 'p1',
      stadiumId: current?.stadiumId ?? 'st1',
      stadiumName: current?.stadiumName ?? 'Al-Nile Stadium',
      pitchName: current?.pitchName ?? 'Pitch A',
      pitchType: current?.pitchType ?? PitchType.fiveASide,
      hasAccessPin: current?.hasAccessPin ?? false,
      paymentSummary: current?.paymentSummary,
    );
  }

  @override
  Future<CustomerBookingListPage> listBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    listRequests.add({'page': page, 'limit': limit, 'status': status});
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (failListWith != null) throw failListWith!;
    final filtered =
        status == null || status.isEmpty
            ? listItems
            : listItems.where((b) => b.status == status).toList();
    final total = listTotal ?? filtered.length;
    final start = (page - 1) * limit;
    final end = start + limit;
    final slice =
        start >= filtered.length
            ? const <CustomerBooking>[]
            : filtered.sublist(
              start,
              end > filtered.length ? filtered.length : end,
            );
    return CustomerBookingListPage(
      items: slice,
      total: total,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<BookingAccessPin> getAccessPin(String bookingId) async {
    accessPinRequests.add(bookingId);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (failAccessPinWith != null) {
      throw failAccessPinWith!;
    }
    final pin = accessPin;
    if (pin == null || pin.isEmpty) {
      throw Exception('PIN not issued');
    }
    return BookingAccessPin(bookingId: bookingId, pin: pin);
  }
}
