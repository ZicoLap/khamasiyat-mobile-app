import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/my_booking_face.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/my_bookings_controller.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

import '../../helpers/fake_bookings_remote.dart';

CustomerBooking _booking({
  String id = 'b-1',
  String status = 'PENDING',
  DateTime? holdsUntil,
  CustomerPaymentSummary? paymentSummary,
}) {
  return CustomerBooking(
    id: id,
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
    holdsUntil: holdsUntil,
    paymentSummary: paymentSummary,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBookingsRemote remote;
  late MyBookingsController controller;

  Future<void> waitLoaded() async {
    for (var i = 0; i < 100; i++) {
      if (controller.state.status != MyBookingsStatus.loading &&
          controller.state.status != MyBookingsStatus.initial) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    fail('MyBookingsController stayed loading');
  }

  setUp(() {
    remote = FakeBookingsRemote(listItems: [_booking()]);
    controller = MyBookingsController(
      bookings: BookingsRepository(remote),
      holdTickInterval: null,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test('initial load fetches first page', () async {
    await controller.loadInitial();
    await waitLoaded();
    expect(controller.state.status, MyBookingsStatus.loaded);
    expect(controller.state.items, hasLength(1));
    expect(remote.listRequests.single['page'], 1);
    expect(remote.listRequests.single['status'], isNull);
  });

  test('refresh replaces rows', () async {
    await controller.loadInitial();
    await waitLoaded();
    remote.listItems = [_booking(id: 'b-2')];
    await controller.refresh();
    expect(controller.state.items.single.id, 'b-2');
    expect(remote.listRequests, hasLength(2));
  });

  test('pagination load more appends without dropping page 1', () async {
    remote.listItems = [for (var i = 0; i < 25; i++) _booking(id: 'b-$i')];
    await controller.loadInitial();
    await waitLoaded();
    expect(controller.state.items, hasLength(20));
    expect(controller.state.hasMore, isTrue);
    await controller.loadMore();
    expect(controller.state.items, hasLength(25));
    expect(controller.state.hasMore, isFalse);
  });

  test('load-more failure preserves already loaded rows', () async {
    remote.listItems = [for (var i = 0; i < 25; i++) _booking(id: 'b-$i')];
    await controller.loadInitial();
    await waitLoaded();
    remote.failListWith = const NetworkException(message: 'offline');
    await controller.loadMore();
    expect(controller.state.items, hasLength(20));
    expect(controller.state.loadMoreError, isNotNull);
    expect(controller.state.status, MyBookingsStatus.loaded);
  });

  test('filter sends status query and replaces list', () async {
    remote.listItems = [
      _booking(id: 'p1', status: 'PENDING'),
      _booking(id: 'c1', status: 'CONFIRMED'),
    ];
    await controller.loadInitial();
    await waitLoaded();
    await controller.setFilter(MyBookingsFilter.confirmed);
    expect(remote.listRequests.last['status'], 'CONFIRMED');
    expect(controller.state.items.map((b) => b.id), ['c1']);
  });

  test('app resume refresh hits list again', () async {
    await controller.loadInitial();
    await waitLoaded();
    await controller.refreshQuiet();
    expect(remote.listRequests, hasLength(2));
  });

  test('expired hold tick refreshes from backend', () async {
    final past = DateTime.utc(2026, 8, 14, 7, 50);
    remote.listItems = [_booking(holdsUntil: past)];
    controller.dispose();
    controller = MyBookingsController(
      bookings: BookingsRepository(remote),
      holdTickInterval: const Duration(milliseconds: 20),
      clock: Clock.fixed(DateTime.utc(2026, 8, 14, 8)),
    );
    await controller.loadInitial();
    await waitLoaded();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(remote.listRequests.length, greaterThan(1));
  });

  test('duplicate load more is ignored while in flight', () async {
    remote
      ..listItems = [for (var i = 0; i < 25; i++) _booking(id: 'b-$i')]
      ..delay = const Duration(milliseconds: 40);
    await controller.loadInitial();
    await waitLoaded();
    final first = controller.loadMore();
    final second = controller.loadMore();
    await Future.wait([first, second]);
    expect(remote.listRequests.where((r) => r['page'] == 2), hasLength(1));
  });
}
