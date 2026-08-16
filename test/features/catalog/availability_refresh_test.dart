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
import 'package:khamasiyat_mobile_app/features/realtime/presentation/pitch_realtime_controller.dart';
import 'package:khamasiyat_mobile_app/shared/platform/pitch_share_actions.dart';

import '../../helpers/fake_availability_remote.dart';
import '../../helpers/fake_bookings_remote.dart';
import '../../helpers/fake_catalog_remote.dart';
import '../../helpers/solid_color_image.dart';

class _NoopShare extends PitchShareActions {
  const _NoopShare();

  @override
  Future<void> shareText(String text) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    FakeBookingsRemote? bookings,
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
        availabilityRealtimeEnabledProvider.overrideWithValue(false),
        bookingsRepositoryProvider.overrideWithValue(
          BookingsRepository(bookings ?? FakeBookingsRemote()),
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
        home: PitchDetailScreen(
          pitchId: pitch.id,
          shareActions: const _NoopShare(),
        ),
      ),
    );
  }

  Future<void> pumpLoaded(
    WidgetTester tester, {
    required FakeAvailabilityRemote availability,
    FakeBookingsRemote? bookings,
    Duration? pollInterval,
    Locale locale = const Locale('en'),
  }) async {
    await load(tester);
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await tester.pumpWidget(
        frame(
          availability: availability,
          bookings: bookings,
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

  testWidgets('polling starts while Pitch Detail is visible', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    await pumpLoaded(
      tester,
      availability: availability,
      pollInterval: const Duration(milliseconds: 50),
    );
    expect(availability.requests, hasLength(1));
    await tester.pump(const Duration(milliseconds: 50));
    expect(availability.requests.length, greaterThanOrEqualTo(2));
  });

  testWidgets('polling stops when leaving the screen', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    await pumpLoaded(
      tester,
      availability: availability,
      pollInterval: const Duration(milliseconds: 50),
    );
    await tester.pump(const Duration(milliseconds: 50));
    final count = availability.requests.length;
    expect(count, greaterThanOrEqualTo(2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 200));
    expect(availability.requests, hasLength(count));
  });

  testWidgets('polling does not overlap in-flight requests', (tester) async {
    final availability = FakeAvailabilityRemote(
      fallback: sampleAvailability(),
      delay: const Duration(milliseconds: 200),
    );
    await pumpLoaded(
      tester,
      availability: availability,
      pollInterval: const Duration(milliseconds: 50),
    );
    expect(availability.requests, hasLength(1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(availability.requests, hasLength(1));
    await tester.pump(const Duration(milliseconds: 50));
    expect(availability.requests, hasLength(2));
    await tester.pump(const Duration(milliseconds: 50));
    expect(availability.requests, hasLength(2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('app resume triggers refetch', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    await pumpLoaded(tester, availability: availability);
    expect(availability.requests, hasLength(1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(availability.requests, hasLength(2));
  });

  testWidgets('pull-to-refresh triggers refetch', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    await pumpLoaded(tester, availability: availability);
    expect(availability.requests, hasLength(1));
    final indicator = tester.state<RefreshIndicatorState>(
      find.byKey(const ValueKey('pitch-availability-refresh')),
    );
    final done = indicator.show();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await done;
    expect(availability.requests, hasLength(2));
  });

  testWidgets('selected slot is preserved if still present', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    await pumpLoaded(tester, availability: availability);
    await selectMorning(tester);
    expect(find.text('Continue'), findsOneWidget);
    final indicator = tester.state<RefreshIndicatorState>(
      find.byKey(const ValueKey('pitch-availability-refresh')),
    );
    final done = indicator.show();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await done;
    expect(find.text('Continue'), findsOneWidget);
    expect(find.textContaining('08:00 → 09:00'), findsWidgets);
  });

  testWidgets('selected slot is cleared if it disappeared', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    await pumpLoaded(tester, availability: availability);
    await selectMorning(tester);
    expect(find.text('Continue'), findsOneWidget);
    availability.fallback = sampleAvailability(
      items: [sampleSlot(id: 'e1', startTime: '20:00', endTime: '21:30')],
    );
    final indicator = tester.state<RefreshIndicatorState>(
      find.byKey(const ValueKey('pitch-availability-refresh')),
    );
    final done = indicator.show();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await done;
    expect(find.text('Continue'), findsNothing);
    expect(
      find.text(
        'This time is no longer available. Please choose another slot.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('empty date shows refresh and choose another date', (
    tester,
  ) async {
    final availability = FakeAvailabilityRemote(
      fallback: sampleAvailability(
        items: [sampleSlot(id: 'n1', date: '2026-08-15', startTime: '09:00')],
      ),
    );
    await pumpLoaded(tester, availability: availability);
    expect(find.text('No available times for this date.'), findsOneWidget);
    expect(find.text('Choose another date'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('quiet poll failure keeps visible slots', (tester) async {
    final availability = FakeAvailabilityRemote(
      fallback: sampleAvailability(),
      failWith: Exception('poll down'),
      failAfterSuccessCount: 1,
    );
    await pumpLoaded(
      tester,
      availability: availability,
      pollInterval: const Duration(milliseconds: 50),
    );
    expect(find.textContaining('08:00 → 09:00'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.textContaining('08:00 → 09:00'), findsOneWidget);
    expect(find.text("Couldn't refresh times."), findsOneWidget);
  });

  testWidgets('Arabic RTL shows available and empty copy', (tester) async {
    final availability = FakeAvailabilityRemote(
      fallback: sampleAvailability(
        items: [sampleSlot(id: 'n1', date: '2026-08-15', startTime: '09:00')],
      ),
    );
    await pumpLoaded(
      tester,
      availability: availability,
      locale: const Locale('ar'),
    );
    expect(find.text('لا توجد أوقات متاحة في هذا التاريخ.'), findsOneWidget);
    expect(find.text('اختر تاريخًا آخر'), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale?.languageCode,
      'ar',
    );
    expect(
      Directionality.of(tester.element(find.text('اختر تاريخًا آخر'))),
      TextDirection.rtl,
    );
  });

  testWidgets('Arabic slot chips keep LTR time range', (tester) async {
    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    await pumpLoaded(
      tester,
      availability: availability,
      locale: const Locale('ar'),
    );
    expect(find.textContaining('08:00 → 09:00'), findsOneWidget);
    expect(find.text('متاح'), findsWidgets);
    expect(find.textContaining('SDG'), findsWidgets);
  });
}
