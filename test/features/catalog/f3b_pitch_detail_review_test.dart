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

/// Pitch Detail visual review — regenerate with:
/// `flutter test --update-goldens test/features/catalog/f3b_pitch_detail_review_test.dart`
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

  Future<void> prepare(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
  }

  Widget frame({required Locale locale, required String name}) {
    final pitch = samplePitchDetail(
      name: name,
      photoUrls: const [
        'https://cdn.example/pitch.jpg',
        'https://cdn.example/pitch2.jpg',
      ],
    );
    return ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          CatalogRepository(FakeCatalogRemote(pitchById: {pitch.id: pitch})),
        ),
        availabilityRepositoryProvider.overrideWithValue(
          AvailabilityRepository(
            FakeAvailabilityRemote(fallback: sampleAvailability()),
          ),
        ),
        availabilityPollIntervalProvider.overrideWithValue(null),
        availabilityRealtimeEnabledProvider.overrideWithValue(false),
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
        home: RepaintBoundary(
          key: const ValueKey('review-root'),
          child: PitchDetailScreen(
            pitchId: pitch.id,
            shareActions: const _NoopShare(),
          ),
        ),
      ),
    );
  }

  Future<void> golden(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('08:00 → 09:00'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('review-root')),
      matchesGoldenFile('../../../docs/f3b-visual-review/$name.png'),
    );
  }

  testWidgets('1 english pitch detail 390', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await prepare(tester);
      await tester.pumpWidget(
        frame(locale: const Locale('en'), name: 'Pitch A'),
      );
      await golden(tester, '01_en_pitch_detail_390');
    });
  });

  testWidgets('2 arabic pitch detail 390', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await prepare(tester);
      await tester.pumpWidget(
        frame(locale: const Locale('ar'), name: 'ملعب أ'),
      );
      await golden(tester, '02_ar_pitch_detail_390');
    });
  });
}
