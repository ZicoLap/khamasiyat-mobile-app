import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/core/clock/stadium_time.dart';
import 'package:khamasiyat_mobile_app/features/availability/data/availability_repository.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/availability_models.dart';
import 'package:khamasiyat_mobile_app/features/availability/presentation/availability_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/pitch_detail_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/pitch_detail_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';
import 'package:khamasiyat_mobile_app/features/realtime/presentation/pitch_realtime_controller.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';
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

  Widget frame({
    required List<Override> overrides,
    Locale locale = const Locale('en'),
    String pitchId = 'p1',
  }) {
    return ProviderScope(
      overrides: overrides,
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
          pitchId: pitchId,
          shareActions: const _NoopShare(),
        ),
      ),
    );
  }

  List<Override> overrides({
    PitchDetail? pitch,
    PitchAvailability? availability,
    FakeBookingsRemote? bookings,
    Object? failPitchWith,
  }) {
    return [
      catalogRepositoryProvider.overrideWithValue(
        CatalogRepository(
          FakeCatalogRemote(
            pitchById: pitch == null ? const {} : {pitch.id: pitch},
            failPitchWith: failPitchWith,
          ),
        ),
      ),
      availabilityRepositoryProvider.overrideWithValue(
        AvailabilityRepository(
          FakeAvailabilityRemote(
            fallback: availability ?? sampleAvailability(),
          ),
        ),
      ),
      availabilityPollIntervalProvider.overrideWithValue(null),
      availabilityRealtimeEnabledProvider.overrideWithValue(false),
      bookingsRepositoryProvider.overrideWithValue(
        BookingsRepository(bookings ?? FakeBookingsRemote()),
      ),
    ];
  }

  test('parses public pitch detail JSON', () {
    final pitch = PitchDetail.fromJson({
      'id': 'p1',
      'name': 'Pitch A',
      'type': 'FIVE_A_SIDE',
      'surfaceType': 'ARTIFICIAL_TURF',
      'isIndoor': false,
      'hasRoof': true,
      'lengthMeters': 40,
      'widthMeters': 20,
      'description': null,
      'photos': [
        {
          'id': 'ph1',
          'url': 'https://cdn.example/p.jpg',
          'displayOrder': 0,
          'isPrimary': true,
        },
      ],
      'stadium': {
        'id': 's1',
        'name': 'Al-Nile Stadium',
        'state': 'KHARTOUM',
        'city': 'KHARTOUM_CITY',
        'timeZone': 'Africa/Khartoum',
      },
    });
    expect(pitch.name, 'Pitch A');
    expect(pitch.type, PitchType.fiveASide);
    expect(pitch.photos.single.isPrimary, isTrue);
    expect(pitch.stadium.timeZone, 'Africa/Khartoum');
  });

  test('availability groups morning afternoon evening', () {
    expect(sampleSlot(startTime: '08:00').period, SlotPeriod.morning);
    expect(sampleSlot(startTime: '15:00').period, SlotPeriod.afternoon);
    expect(sampleSlot(startTime: '20:00').period, SlotPeriod.evening);
  });

  testWidgets('renders pitch name type and available slots', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await tester.pumpWidget(
        frame(
          overrides: overrides(
            pitch: samplePitchDetail(
              photoUrls: const ['https://cdn.example/p.jpg'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pitch A'), findsOneWidget);
      expect(find.text('5-a-side'), findsWidgets);
      expect(find.textContaining('08:00 → 09:00'), findsOneWidget);
      expect(find.textContaining('1h'), findsWidgets);
      expect(find.textContaining('15,000 SDG'), findsWidgets);
      expect(find.text('Available'), findsWidgets);
      expect(find.textContaining('Africa/Khartoum'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    });
  });

  testWidgets('selecting a slot shows the booking bar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await tester.pumpWidget(
        frame(
          overrides: overrides(
            pitch: samplePitchDetail(
              photoUrls: const ['https://cdn.example/p.jpg'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.textContaining('08:00 → 09:00'));
      await tester.tap(find.textContaining('08:00 → 09:00'));
      await tester.pumpAndSettle();
      expect(find.text('Continue'), findsOneWidget);
      expect(find.textContaining('08:00 → 09:00'), findsWidgets);
    });
  });

  testWidgets('Continue does not call booking API and opens review', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bookings = FakeBookingsRemote();
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await tester.pumpWidget(
        frame(
          overrides: overrides(
            pitch: samplePitchDetail(
              photoUrls: const ['https://cdn.example/p.jpg'],
            ),
            bookings: bookings,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.textContaining('08:00 → 09:00'));
      await tester.tap(find.textContaining('08:00 → 09:00'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(bookings.createdOccurrenceIds, isEmpty);
      expect(find.text('Review booking'), findsOneWidget);
      expect(find.text('Book this slot'), findsOneWidget);
    });
  });

  testWidgets('error state offers retry', (tester) async {
    await tester.pumpWidget(
      frame(overrides: overrides(failPitchWith: Exception('offline'))),
    );
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load pitch"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  test('stadium civil date helpers', () {
    expect(
      StadiumTime.todayIsoDate(utcNow: DateTime.utc(2026, 8, 14, 7)),
      '2026-08-14',
    );
    expect(StadiumTime.addIsoDateDays('2026-08-14', 1), '2026-08-15');
  });
}
