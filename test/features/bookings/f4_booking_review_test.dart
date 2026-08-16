import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/core/storage/secure_token_store.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_repository.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/availability/data/availability_repository.dart';
import 'package:khamasiyat_mobile_app/features/availability/presentation/availability_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_review_draft.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_review_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_review_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';
import 'package:khamasiyat_mobile_app/features/realtime/presentation/pitch_realtime_controller.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_auth_remote.dart';
import '../../helpers/fake_availability_remote.dart';
import '../../helpers/fake_bookings_remote.dart';
import '../../helpers/fake_catalog_remote.dart';
import '../../helpers/solid_color_image.dart';

/// F4 Booking Summary visual review — regenerate with:
/// `flutter test --update-goldens test/features/bookings/f4_booking_review_test.dart`
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

  BookingReviewDraft draft({
    List<String> photoUrls = const ['https://cdn.example/p.jpg'],
  }) {
    final pitch = samplePitchDetail(name: 'Pitch Bahri', photoUrls: photoUrls);
    return BookingReviewDraft.fromPitchAndSlot(
      pitch: pitch,
      slot: sampleSlot(
        id: 'm1',
        date: '2026-08-15',
        startTime: '20:00',
        endTime: '21:30',
        priceSdg: 50000,
      ),
    );
  }

  Future<void> prepare(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
  }

  Widget frame({
    required Locale locale,
    required BookingReviewDraft reviewDraft,
  }) {
    final pitch = samplePitchDetail(
      name: 'Pitch Bahri',
      photoUrls:
          reviewDraft.photoUrl == null ? const [] : [reviewDraft.photoUrl!],
    );
    final authController = AuthController(
      repository: AuthRepository(
        api: FakeAuthRemote(),
        tokenStore: InMemoryTokenStore(),
      ),
      restoreOnStart: false,
      initialState: AuthAuthenticated(
        buildAuthUser(name: 'Ahmed Hassan', phone: '+249912345678'),
      ),
    );
    return RepaintBoundary(
      key: const ValueKey('review-root'),
      child: ProviderScope(
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
          bookingReviewDraftProvider.overrideWith((ref) => reviewDraft),
          authControllerProvider.overrideWith((ref) => authController),
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
          home: const BookingReviewScreen(),
        ),
      ),
    );
  }

  Future<void> golden(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('review-root')),
      matchesGoldenFile('../../../docs/f4-visual-review/$name.png'),
    );
  }

  testWidgets('1 en booking summary 390', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(locale: const Locale('en'), reviewDraft: draft()),
      );
      await golden(tester, '01_en_booking_summary_390');
    });
  });

  testWidgets('2 ar booking summary 390', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(locale: const Locale('ar'), reviewDraft: draft()),
      );
      await golden(tester, '02_ar_booking_summary_390');
    });
  });

  testWidgets('3 en booking summary 320', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await prepare(tester, const Size(320, 720));
      await tester.pumpWidget(
        frame(locale: const Locale('en'), reviewDraft: draft()),
      );
      await golden(tester, '03_en_booking_summary_320');
    });
  });

  testWidgets('4 missing photo state', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(
          locale: const Locale('en'),
          reviewDraft: draft(photoUrls: const []),
        ),
      );
      await golden(tester, '04_missing_photo');
    });
  });
}
