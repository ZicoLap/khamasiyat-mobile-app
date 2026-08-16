import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/features/availability/data/availability_repository.dart';
import 'package:khamasiyat_mobile_app/features/availability/presentation/availability_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/pitch_detail_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';
import 'package:khamasiyat_mobile_app/features/realtime/domain/realtime_models.dart';
import 'package:khamasiyat_mobile_app/features/realtime/presentation/pitch_realtime_controller.dart';
import 'package:khamasiyat_mobile_app/shared/platform/pitch_share_actions.dart';

import '../../helpers/fake_availability_remote.dart';
import '../../helpers/fake_bookings_remote.dart';
import '../../helpers/fake_catalog_remote.dart';
import '../../helpers/fake_realtime.dart';
import '../../helpers/solid_color_image.dart';

class _NoopShare extends PitchShareActions {
  const _NoopShare();

  @override
  Future<void> shareText(String text) async {}
}

const _realtimeDebounce = Duration(milliseconds: 40);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('isolated notifier increments generation on matching event', (
    tester,
  ) async {
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    final container = ProviderContainer(
      overrides: [
        availabilityRealtimeEnabledProvider.overrideWithValue(true),
        availabilityRealtimeDebounceProvider.overrideWithValue(
          _realtimeDebounce,
        ),
        realtimeTicketRemoteProvider.overrideWithValue(tickets),
        sseConnectorProvider.overrideWithValue(sse),
      ],
    );
    addTearDown(container.dispose);
    final generations = <int>[];
    container.listen<PitchRealtimeState>(
      pitchRealtimeProvider('p1'),
      (_, next) => generations.add(next.generation),
      fireImmediately: true,
    );
    await tester.pump();
    expect(sse.hasListener, isTrue);
    sse.emit(availabilityChangedEvent(pitchId: 'p1'));
    await tester.pump();
    expect(generations, contains(1));
  });

  setUpAll(() {
    StadiumPhoto.debugImageProviderForUrl = (_) {
      return const SolidColorImageProvider(Color(0xFF1F6B4A), dimension: 128);
    };
  });
  tearDownAll(() {
    StadiumPhoto.debugImageProviderForUrl = null;
  });

  Future<void> load(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget frame({
    required FakeAvailabilityRemote availability,
    required FakeRealtimeTicketRemote tickets,
    required FakeSseConnector sse,
    Duration? pollInterval,
    Locale locale = const Locale('en'),
  }) {
    final pitch = samplePitchDetail(
      photoUrls: const ['https://cdn.example/p.jpg'],
    );
    return ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          CatalogRepository(FakeCatalogRemote(pitchById: {pitch.id: pitch})),
        ),
        availabilityRepositoryProvider.overrideWithValue(
          AvailabilityRepository(availability),
        ),
        availabilityPollIntervalProvider.overrideWithValue(pollInterval),
        availabilityRealtimeEnabledProvider.overrideWithValue(true),
        availabilityRealtimeDebounceProvider.overrideWithValue(
          _realtimeDebounce,
        ),
        realtimeTicketRemoteProvider.overrideWithValue(tickets),
        sseConnectorProvider.overrideWithValue(sse),
        bookingsRepositoryProvider.overrideWithValue(
          BookingsRepository(FakeBookingsRemote()),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const PitchDetailScreen(
          pitchId: 'p1',
          shareActions: _NoopShare(),
        ),
      ),
    );
  }

  Future<void> pumpLoaded(
    WidgetTester tester, {
    required FakeAvailabilityRemote availability,
    required FakeRealtimeTicketRemote tickets,
    required FakeSseConnector sse,
    Duration? pollInterval,
    Locale locale = const Locale('en'),
  }) async {
    await load(tester);
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await tester.pumpWidget(
        frame(
          availability: availability,
          tickets: tickets,
          sse: sse,
          pollInterval: pollInterval,
          locale: locale,
        ),
      );
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 400));
    });
  }

  Future<void> selectMorning(WidgetTester tester) async {
    final slot = find.textContaining('08:00 → 09:00');
    await tester.ensureVisible(slot);
    await tester.tap(slot);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('connection is created for the current pitch', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
    );
    expect(tickets.requestedPitchIds, ['p1']);
    expect(sse.connectCount, 1);
    expect(sse.paths, ['/realtime/stream']);
    expect(sse.tickets, ['rt_p1']);
    expect(sse.openConnections, 1);
    expect(sse.hasListener, isTrue);
  });

  testWidgets('matching event triggers a quiet GET refetch', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
    );
    expect(availability.requests, hasLength(1));
    expect(sse.hasListener, isTrue);
    sse.emit(availabilityChangedEvent(pitchId: 'p1'));
    await tester.pump();
    expect(availability.requests, hasLength(1));
    await tester.pump(_realtimeDebounce);
    await tester.pump();
    expect(availability.requests, hasLength(2));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('event for another pitch is ignored', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
    );
    sse.emit(availabilityChangedEvent(pitchId: 'other-pitch'));
    await tester.pump(_realtimeDebounce);
    await tester.pump(const Duration(milliseconds: 1));
    expect(availability.requests, hasLength(1));
  });

  testWidgets('heartbeat does not trigger a refetch', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
    );
    sse.emit(heartbeatEvent());
    await tester.pump(_realtimeDebounce);
    expect(availability.requests, hasLength(1));
  });

  testWidgets('rapid events are coalesced into one GET', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
    );
    sse.emit(availabilityChangedEvent(pitchId: 'p1', reason: 'held'));
    await tester.pump(const Duration(milliseconds: 10));
    sse.emit(availabilityChangedEvent(pitchId: 'p1', reason: 'created'));
    await tester.pump(const Duration(milliseconds: 10));
    sse.emit(availabilityChangedEvent(pitchId: 'p1', reason: 'released'));
    await tester.pump(_realtimeDebounce);
    await tester.pump();
    expect(availability.requests, hasLength(2));
  });

  testWidgets('leaving the screen disposes the realtime connection', (
    tester,
  ) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
    );
    expect(sse.openConnections, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(sse.openConnections, 0);
    final connects = sse.connectCount;
    final gets = availability.requests.length;
    sse.emit(availabilityChangedEvent(pitchId: 'p1'));
    await tester.pump(_realtimeDebounce);
    await tester.pump(const Duration(milliseconds: 400));
    expect(sse.connectCount, connects);
    expect(availability.requests, hasLength(gets));
    expect(tickets.requestedPitchIds, ['p1']);
  });

  testWidgets(
    'app background pauses SSE and resume reconnects plus refetches',
    (tester) async {
      final availability = FakeAvailabilityRemote(
        fallback: sampleAvailability(),
      );
      final tickets = FakeRealtimeTicketRemote();
      final sse = FakeSseConnector();
      await pumpLoaded(
        tester,
        availability: availability,
        tickets: tickets,
        sse: sse,
      );
      expect(sse.openConnections, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(sse.openConnections, 0);
      expect(availability.requests, hasLength(1));
      sse.emit(availabilityChangedEvent(pitchId: 'p1'));
      await tester.pump(_realtimeDebounce);
      expect(availability.requests, hasLength(1));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(availability.requests, hasLength(2));
      expect(tickets.requestedPitchIds, ['p1', 'p1']);
      expect(sse.connectCount, 2);
      expect(sse.openConnections, 1);
    },
  );

  testWidgets('SSE failure still refreshes through polling', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    final tickets = FakeRealtimeTicketRemote(
      failWith: Exception('ticket down'),
    );
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
      pollInterval: const Duration(milliseconds: 50),
    );
    expect(availability.requests, hasLength(1));
    expect(sse.connectCount, 0);
    await tester.pump(const Duration(milliseconds: 50));
    expect(availability.requests.length, greaterThanOrEqualTo(2));
    expect(find.textContaining('08:00 → 09:00'), findsOneWidget);
  });

  testWidgets('newly created slot appears after event and refetch', (
    tester,
  ) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
    );
    expect(find.textContaining('22:00 → 23:00'), findsNothing);
    availability.fallback = sampleAvailability(
      items: [
        ...sampleAvailability().items,
        sampleSlot(id: 'new1', startTime: '22:00', endTime: '23:00'),
      ],
    );
    sse.emit(availabilityChangedEvent(pitchId: 'p1', reason: 'created'));
    await tester.pump(_realtimeDebounce);
    await tester.pump();
    expect(find.textContaining('22:00 → 23:00'), findsOneWidget);
  });

  testWidgets('disappeared selected slot clears selection after refetch', (
    tester,
  ) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
    );
    await selectMorning(tester);
    expect(find.text('Continue'), findsOneWidget);
    availability.fallback = sampleAvailability(
      items: [sampleSlot(id: 'e1', startTime: '20:00', endTime: '21:30')],
    );
    sse.emit(availabilityChangedEvent(pitchId: 'p1', reason: 'held'));
    await tester.pump(_realtimeDebounce);
    await tester.pump();
    expect(find.text('Continue'), findsNothing);
    expect(
      find.text(
        'This time is no longer available. Please choose another slot.',
      ),
      findsOneWidget,
    );
    expect(find.text('Held'), findsNothing);
    expect(find.text('Booked'), findsNothing);
  });

  testWidgets('SSE hints do not start overlapping GETs', (tester) async {
    final availability = FakeAvailabilityRemote(
      fallback: sampleAvailability(),
      delay: const Duration(milliseconds: 200),
    );
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(availability.requests, hasLength(1));
    sse.emit(availabilityChangedEvent(pitchId: 'p1'));
    await tester.pump(_realtimeDebounce);
    expect(availability.requests, hasLength(2));
    sse.emit(availabilityChangedEvent(pitchId: 'p1'));
    await tester.pump(const Duration(milliseconds: 20));
    sse.emit(availabilityChangedEvent(pitchId: 'p1'));
    await tester.pump(_realtimeDebounce);
    expect(availability.requests, hasLength(2));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('English slot copy stays unchanged with realtime', (
    tester,
  ) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
    );
    expect(find.text('Available'), findsWidgets);
    expect(find.textContaining('08:00 → 09:00'), findsOneWidget);
    expect(find.text('Held'), findsNothing);
    expect(find.text('Booked'), findsNothing);
  });

  testWidgets('Arabic empty-date copy stays unchanged with realtime', (
    tester,
  ) async {
    final availability = FakeAvailabilityRemote(
      fallback: sampleAvailability(
        items: [sampleSlot(id: 'n1', date: '2026-08-15', startTime: '09:00')],
      ),
    );
    final tickets = FakeRealtimeTicketRemote();
    final sse = FakeSseConnector();
    await pumpLoaded(
      tester,
      availability: availability,
      tickets: tickets,
      sse: sse,
      locale: const Locale('ar'),
    );
    expect(find.text('لا توجد أوقات متاحة في هذا التاريخ.'), findsOneWidget);
    expect(find.text('اختر تاريخًا آخر'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('اختر تاريخًا آخر'))),
      TextDirection.rtl,
    );
  });
}
