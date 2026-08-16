import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_detail_controller.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

import '../../helpers/fake_bookings_remote.dart';
import '../../helpers/fake_catalog_remote.dart';

CustomerBooking _booking({
  String id = 'b-1',
  String status = 'CONFIRMED',
  bool hasAccessPin = true,
  DateTime? holdsUntil,
  CustomerPaymentSummary? paymentSummary,
}) {
  return CustomerBooking(
    id: id,
    status: status,
    date: '2026-08-15',
    startTime: '20:00',
    endTime: '21:30',
    priceSdg: 50000,
    currency: 'SDG',
    slotOccurrenceId: 'occ-1',
    pitchId: 'p1',
    stadiumId: 'st1',
    stadiumName: 'Al-Nile Stadium',
    pitchName: 'Pitch Bahri',
    pitchType: PitchType.fiveASide,
    hasAccessPin: hasAccessPin,
    holdsUntil: holdsUntil,
    paymentSummary: paymentSummary,
  );
}

BookingDetailController _controller({
  required FakeBookingsRemote bookings,
  FakeCatalogRemote? catalog,
  Clock clock = const Clock(),
}) {
  return BookingDetailController(
    bookingId: 'b-1',
    bookings: BookingsRepository(bookings),
    catalog: CatalogRepository(
      catalog ??
          FakeCatalogRemote(
            stadiumById: {'st1': sampleStadiumDetail(id: 'st1')},
            pitchById: {'p1': samplePitchDetail(name: 'Pitch Bahri')},
          ),
    ),
    holdTickInterval: null,
    clock: clock,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initial load fetches booking and venue, not PIN', () async {
    final remote = FakeBookingsRemote(booking: _booking());
    final controller = _controller(bookings: remote);
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.state.status, BookingDetailStatus.loaded);
    expect(controller.state.booking?.id, 'b-1');
    expect(controller.state.stadium?.id, 'st1');
    expect(controller.state.pitch?.id, 'p1');
    expect(remote.accessPinRequests, isEmpty);
    expect(controller.state.pin, isNull);
    expect(controller.state.offersPin, isTrue);
  });

  test('refresh reloads booking without fetching PIN', () async {
    final remote = FakeBookingsRemote(booking: _booking());
    final controller = _controller(bookings: remote);
    addTearDown(controller.dispose);
    await controller.load();
    remote.getBookingIds.clear();

    await controller.refresh();

    expect(remote.getBookingIds, ['b-1']);
    expect(remote.accessPinRequests, isEmpty);
  });

  test('resume refresh reloads booking quietly', () async {
    final remote = FakeBookingsRemote(booking: _booking());
    final controller = _controller(bookings: remote);
    addTearDown(controller.dispose);
    await controller.load();
    remote.getBookingIds.clear();

    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);

    expect(remote.getBookingIds, ['b-1']);
  });

  test(
    'PIN is fetched lazily, stays in session, hide/show does not refetch',
    () async {
      final remote = FakeBookingsRemote(booking: _booking());
      final controller = _controller(bookings: remote);
      addTearDown(controller.dispose);
      await controller.load();

      await controller.showPin();
      expect(remote.accessPinRequests, ['b-1']);
      expect(controller.state.pinVisible, isTrue);
      expect(controller.state.pin, '842157');

      controller.hidePin();
      expect(controller.state.pinVisible, isFalse);
      expect(controller.state.pin, '842157');

      await controller.showPin();
      expect(remote.accessPinRequests, ['b-1']);
      expect(controller.state.pinVisible, isTrue);
    },
  );

  test('PIN retry after local error', () async {
    final remote = FakeBookingsRemote(
      booking: _booking(),
      failAccessPinWith: const NetworkException(message: 'offline'),
    );
    final controller = _controller(bookings: remote);
    addTearDown(controller.dispose);
    await controller.load();

    await controller.showPin();
    expect(controller.state.pinError, isNotNull);
    expect(controller.state.pinVisible, isFalse);
    expect(controller.state.status, BookingDetailStatus.loaded);

    remote.failAccessPinWith = null;
    await controller.retryPin();
    expect(controller.state.pinError, isNull);
    expect(controller.state.pinVisible, isTrue);
    expect(controller.state.pin, '842157');
  });

  test('PIN is not fetched when hasAccessPin is false', () async {
    final remote = FakeBookingsRemote(booking: _booking(hasAccessPin: false));
    final controller = _controller(bookings: remote);
    addTearDown(controller.dispose);
    await controller.load();
    await controller.showPin();
    expect(remote.accessPinRequests, isEmpty);
    expect(controller.state.offersPin, isFalse);
  });

  test('load failure without booking becomes page error', () async {
    final remote = FakeBookingsRemote(
      failWith: const NetworkException(message: 'offline'),
      remainingFailures: -1,
    );
    final controller = _controller(bookings: remote);
    addTearDown(controller.dispose);
    await controller.load();
    expect(controller.state.status, BookingDetailStatus.failure);
    expect(controller.state.booking, isNull);
  });

  test('venue enrichment failure still loads booking', () async {
    final remote = FakeBookingsRemote(booking: _booking());
    final controller = _controller(
      bookings: remote,
      catalog: FakeCatalogRemote(
        failDetailWith: Exception('stadium down'),
        failPitchWith: Exception('pitch down'),
      ),
    );
    addTearDown(controller.dispose);
    await controller.load();
    expect(controller.state.status, BookingDetailStatus.loaded);
    expect(controller.state.booking?.id, 'b-1');
    expect(controller.state.stadium, isNull);
    expect(controller.state.pitch, isNull);
  });

  test('refresh clears PIN if booking is no longer eligible', () async {
    final remote = FakeBookingsRemote(booking: _booking());
    final controller = _controller(bookings: remote);
    addTearDown(controller.dispose);
    await controller.load();
    await controller.showPin();
    expect(controller.state.pin, isNotNull);

    remote.booking = _booking(status: 'COMPLETED', hasAccessPin: true);
    await controller.refresh();
    expect(controller.state.pin, isNull);
    expect(controller.state.pinVisible, isFalse);
    expect(controller.state.offersPin, isFalse);
  });
}
