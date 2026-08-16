import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/core/errors/api_error.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/core/storage/secure_token_store.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_repository.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/availability/data/availability_repository.dart';
import 'package:khamasiyat_mobile_app/features/availability/presentation/availability_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_attempt_keys.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_models.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_review_draft.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_review_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_review_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/pitch_detail_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';
import 'package:khamasiyat_mobile_app/features/payments/data/payments_repository.dart';
import 'package:khamasiyat_mobile_app/features/payments/presentation/payment_controller.dart';
import 'package:khamasiyat_mobile_app/features/realtime/presentation/pitch_realtime_controller.dart';
import 'package:khamasiyat_mobile_app/shared/platform/pitch_share_actions.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_auth_remote.dart';
import '../../helpers/fake_availability_remote.dart';
import '../../helpers/fake_bookings_remote.dart';
import '../../helpers/fake_catalog_remote.dart';
import '../../helpers/fake_payments_remote.dart';
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

  BookingReviewDraft sampleDraft() {
    final pitch = samplePitchDetail(
      photoUrls: const ['https://cdn.example/p.jpg'],
    );
    return BookingReviewDraft.fromPitchAndSlot(
      pitch: pitch,
      slot: sampleSlot(id: 'm1', startTime: '08:00', endTime: '09:00'),
    );
  }

  List<Override> baseOverrides({
    FakeBookingsRemote? bookings,
    BookingReviewDraft? draft,
  }) {
    final pitch = samplePitchDetail(
      photoUrls: const ['https://cdn.example/p.jpg'],
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
    return [
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
        BookingsRepository(bookings ?? FakeBookingsRemote()),
      ),
      paymentsRepositoryProvider.overrideWithValue(
        PaymentsRepository(FakePaymentsRemote(), FakeReceiptUploadClient()),
      ),
      paymentPollIntervalProvider.overrideWithValue(null),
      paymentHoldTickIntervalProvider.overrideWithValue(null),
      bookingReviewDraftProvider.overrideWith((ref) => draft ?? sampleDraft()),
      authControllerProvider.overrideWith((ref) => authController),
    ];
  }

  Widget reviewApp({
    required List<Override> overrides,
    Locale locale = const Locale('en'),
    BookingAttemptKeys? attemptKeys,
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
        home: BookingReviewScreen(bookingAttemptKeys: attemptKeys),
      ),
    );
  }

  test('CreatedBooking parses holdsUntil', () {
    final booking = CreatedBooking.fromJson({
      'id': 'b1',
      'status': 'PENDING',
      'date': '2026-08-14',
      'startTime': '08:00',
      'endTime': '09:00',
      'priceSdg': 15000,
      'slotOccurrenceId': 'm1',
      'holdsUntil': '2026-08-14T08:15:00.000Z',
    });
    expect(booking.status, 'PENDING');
    expect(booking.holdsUntil, DateTime.utc(2026, 8, 14, 8, 15));
  });

  testWidgets('summary shows stadium pitch date time duration price', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(reviewApp(overrides: baseOverrides()));
    await tester.pumpAndSettle();

    expect(find.text('Review booking'), findsOneWidget);
    expect(find.text('Al-Nile Stadium'), findsOneWidget);
    expect(find.text('Pitch A'), findsOneWidget);
    expect(find.text('5-a-side'), findsOneWidget);
    expect(find.textContaining('Aug'), findsOneWidget);
    expect(find.textContaining('08:00 → 09:00'), findsOneWidget);
    expect(find.textContaining('1h'), findsWidgets);
    expect(find.textContaining('15,000 SDG'), findsWidgets);
    expect(find.text('Book this slot'), findsOneWidget);
    expect(find.text('Your booking'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Ahmed Hassan'), findsOneWidget);
    expect(find.text('+249912345678'), findsOneWidget);
    expect(find.text('Price details'), findsOneWidget);
    expect(
      find.textContaining('Your slot', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('Back returns without backend call', (tester) async {
    final bookings = FakeBookingsRemote();
    await tester.pumpWidget(
      reviewApp(overrides: baseOverrides(bookings: bookings)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(bookings.createdOccurrenceIds, isEmpty);
  });

  testWidgets('Arabic RTL summary', (tester) async {
    await tester.pumpWidget(
      reviewApp(overrides: baseOverrides(), locale: const Locale('ar')),
    );
    await tester.pumpAndSettle();
    expect(find.text('مراجعة الحجز'), findsOneWidget);
    expect(find.text('احجز هذا الموعد'), findsOneWidget);
    expect(find.text('حجزك'), findsOneWidget);
    expect(find.text('إلغاء'), findsNothing);
    expect(
      Directionality.of(tester.element(find.text('مراجعة الحجز'))),
      TextDirection.rtl,
    );
  });

  testWidgets('Book this slot posts once and shows reserved sheet', (
    tester,
  ) async {
    final bookings = FakeBookingsRemote();
    var n = 0;
    await tester.pumpWidget(
      reviewApp(
        overrides: baseOverrides(bookings: bookings),
        attemptKeys: BookingAttemptKeys(createKey: () => 'k${++n}'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book this slot'));
    await tester.pumpAndSettle();
    expect(bookings.createdOccurrenceIds, ['m1']);
    expect(bookings.idempotencyKeys, ['k1']);
    expect(find.text('Slot reserved'), findsOneWidget);
    expect(find.text('Continue to payment'), findsOneWidget);
    expect(find.textContaining('Reservation held until'), findsOneWidget);
  });

  testWidgets('duplicate Book this slot taps are ignored', (tester) async {
    final bookings = FakeBookingsRemote(
      delay: const Duration(milliseconds: 300),
    );
    await tester.pumpWidget(
      reviewApp(overrides: baseOverrides(bookings: bookings)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book this slot'));
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(bookings.createdOccurrenceIds, ['m1']);
    expect(bookings.idempotencyKeys, hasLength(1));
  });

  testWidgets('same idempotency key reused after retryable failure', (
    tester,
  ) async {
    final bookings = FakeBookingsRemote(
      failWith: const NetworkException(message: 'offline'),
      remainingFailures: 1,
    );
    var n = 0;
    await tester.pumpWidget(
      reviewApp(
        overrides: baseOverrides(bookings: bookings),
        attemptKeys: BookingAttemptKeys(createKey: () => 'k${++n}'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book this slot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book this slot'));
    await tester.pumpAndSettle();
    expect(bookings.idempotencyKeys, ['k1', 'k1']);
    expect(bookings.createdOccurrenceIds, ['m1']);
  });

  testWidgets('Continue to payment opens payment with booking id', (
    tester,
  ) async {
    final bookings = FakeBookingsRemote();
    await tester.pumpWidget(
      reviewApp(overrides: baseOverrides(bookings: bookings)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book this slot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to payment'));
    await tester.pumpAndSettle();
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Your slot is reserved'), findsOneWidget);
    expect(find.text('Choose a payment method'), findsOneWidget);
    expect(find.textContaining('Al-Nile Stadium'), findsOneWidget);
    expect(find.textContaining('Pitch A'), findsOneWidget);
  });

  testWidgets('409 shows conflict and returns to pitch detail cleared', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final availability = FakeAvailabilityRemote(fallback: sampleAvailability());
    final bookings = FakeBookingsRemote(
      failWith: ApiException(
        error: const ApiError(code: 'BOOKING_NOT_AVAILABLE', message: 'taken'),
      ),
      remainingFailures: -1,
    );
    final pitch = samplePitchDetail(
      photoUrls: const ['https://cdn.example/p.jpg'],
    );

    await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 7)), () async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogRepositoryProvider.overrideWithValue(
              CatalogRepository(
                FakeCatalogRemote(pitchById: {pitch.id: pitch}),
              ),
            ),
            availabilityRepositoryProvider.overrideWithValue(
              AvailabilityRepository(availability),
            ),
            availabilityPollIntervalProvider.overrideWithValue(null),
            availabilityRealtimeEnabledProvider.overrideWithValue(false),
            bookingsRepositoryProvider.overrideWithValue(
              BookingsRepository(bookings),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            locale: const Locale('en'),
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
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.textContaining('08:00 → 09:00'));
      await tester.tap(find.textContaining('08:00 → 09:00'));
      await tester.pumpAndSettle();
      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Book this slot'), findsOneWidget);
      await tester.tap(find.text('Book this slot'));
      await tester.pumpAndSettle();
      expect(find.text('This time is no longer available.'), findsOneWidget);
      expect(
        find.textContaining('Someone else booked this slot'),
        findsOneWidget,
      );
      await tester.tap(find.text('Choose another time'));
      await tester.pumpAndSettle();
      expect(find.text('Continue'), findsNothing);
      expect(bookings.createdOccurrenceIds, isEmpty);
      expect(availability.requests.length, greaterThanOrEqualTo(2));
    });
  });
}
