import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_detail_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_detail_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';
import 'package:khamasiyat_mobile_app/features/payments/data/payments_repository.dart';
import 'package:khamasiyat_mobile_app/features/payments/presentation/payment_controller.dart';
import 'package:khamasiyat_mobile_app/features/payments/presentation/payment_screen.dart';
import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

import '../../helpers/fake_bookings_remote.dart';
import '../../helpers/fake_catalog_remote.dart';
import '../../helpers/fake_payments_remote.dart';
import '../../helpers/solid_color_image.dart';

CustomerBooking _booking({
  String id = 'b-1',
  String status = 'CONFIRMED',
  bool hasAccessPin = true,
  DateTime? holdsUntil,
  CustomerPaymentSummary? paymentSummary,
  String pitchName = 'Pitch Bahri',
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
    pitchName: pitchName,
    pitchType: PitchType.fiveASide,
    hasAccessPin: hasAccessPin,
    holdsUntil: holdsUntil,
    paymentSummary: paymentSummary,
  );
}

Widget _app({
  required FakeBookingsRemote bookings,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      bookingsRepositoryProvider.overrideWithValue(
        BookingsRepository(bookings),
      ),
      catalogRepositoryProvider.overrideWithValue(
        CatalogRepository(
          FakeCatalogRemote(
            stadiumById: {
              'st1': sampleStadiumDetail(
                id: 'st1',
                photoUrls: const ['https://cdn.example/hero.jpg'],
              ),
            },
            pitchById: {
              'p1': samplePitchDetail(
                name: 'Pitch Bahri',
                photoUrls: const ['https://cdn.example/hero.jpg'],
              ),
            },
          ),
        ),
      ),
      paymentsRepositoryProvider.overrideWithValue(
        PaymentsRepository(FakePaymentsRemote(), FakeReceiptUploadClient()),
      ),
      bookingDetailHoldTickIntervalProvider.overrideWithValue(null),
      paymentPollIntervalProvider.overrideWithValue(null),
      paymentHoldTickIntervalProvider.overrideWithValue(null),
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
      home: const BookingDetailScreen(bookingId: 'b-1'),
    ),
  );
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

  Future<void> prepare(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
  }

  testWidgets('loading shows booking-detail skeleton', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        bookings: FakeBookingsRemote(
          booking: _booking(),
          delay: const Duration(milliseconds: 80),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('booking-detail-skeleton')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('full page error keeps back and offers retry', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        bookings: FakeBookingsRemote(
          failWith: const NetworkException(message: 'offline'),
          remainingFailures: -1,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(BookingDetailScreen)),
    );
    expect(find.byKey(const ValueKey('booking-detail-error')), findsOneWidget);
    expect(find.text(l10n.bookingDetailLoadFailed), findsOneWidget);
    expect(find.text(l10n.myBookingsTryAgain), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('confirmed ticket shows hidden PIN then reveals it', (
    tester,
  ) async {
    await prepare(tester, const Size(390, 844));
    final bookings = FakeBookingsRemote(booking: _booking());
    await tester.pumpWidget(_app(bookings: bookings));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(BookingDetailScreen)),
    );
    expect(find.text(l10n.myBookingsStatusConfirmed), findsWidgets);
    expect(find.text('Al-Nile Stadium'), findsOneWidget);
    expect(find.textContaining('Pitch Bahri'), findsWidgets);
    expect(find.text('20:00 → 21:30'), findsWidgets);
    expect(
      find.byKey(const ValueKey('booking-detail-pin-hidden')),
      findsOneWidget,
    );
    expect(bookings.accessPinRequests, isEmpty);

    await tester.ensureVisible(find.text(l10n.bookingDetailShowPin));
    await tester.tap(find.text(l10n.bookingDetailShowPin));
    await tester.pumpAndSettle();
    expect(bookings.accessPinRequests, ['b-1']);
    expect(
      find.byKey(const ValueKey('booking-detail-pin-revealed')),
      findsOneWidget,
    );
    expect(find.text('8'), findsWidgets);
    expect(find.text(l10n.bookingDetailHidePin), findsOneWidget);

    await tester.tap(find.text(l10n.bookingDetailHidePin));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('booking-detail-pin-hidden')),
      findsOneWidget,
    );
  });

  testWidgets('no PIN card when hasAccessPin is false', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        bookings: FakeBookingsRemote(booking: _booking(hasAccessPin: false)),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(BookingDetailScreen)),
    );
    expect(find.byKey(const ValueKey('booking-detail-pin-card')), findsNothing);
    expect(find.text(l10n.bookingDetailShowPin), findsNothing);
  });

  testWidgets('PIN error stays local and can retry', (tester) async {
    await prepare(tester, const Size(390, 844));
    final bookings = FakeBookingsRemote(
      booking: _booking(),
      failAccessPinWith: const NetworkException(message: 'offline'),
    );
    await tester.pumpWidget(_app(bookings: bookings));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(BookingDetailScreen)),
    );
    await tester.ensureVisible(find.text(l10n.bookingDetailShowPin));
    await tester.tap(find.text(l10n.bookingDetailShowPin));
    await tester.pumpAndSettle();
    expect(find.text('Al-Nile Stadium'), findsOneWidget);
    expect(find.text(l10n.bookingDetailPinLoadFailed), findsOneWidget);
    expect(
      find.byKey(const ValueKey('booking-detail-pin-error')),
      findsOneWidget,
    );

    bookings.failAccessPinWith = null;
    await tester.tap(find.text(l10n.myBookingsTryAgain));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('booking-detail-pin-revealed')),
      findsOneWidget,
    );
  });

  testWidgets('PENDING payment-required Complete payment opens same booking', (
    tester,
  ) async {
    await prepare(tester, const Size(390, 844));
    final hold = DateTime.utc(2026, 8, 15, 18, 12);
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 18)), () async {
      final bookings = FakeBookingsRemote(
        booking: _booking(
          status: 'PENDING',
          hasAccessPin: false,
          holdsUntil: hold,
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingsRepositoryProvider.overrideWithValue(
              BookingsRepository(bookings),
            ),
            catalogRepositoryProvider.overrideWithValue(
              CatalogRepository(FakeCatalogRemote()),
            ),
            paymentsRepositoryProvider.overrideWithValue(
              PaymentsRepository(
                FakePaymentsRemote(),
                FakeReceiptUploadClient(),
              ),
            ),
            bookingDetailHoldTickIntervalProvider.overrideWithValue(null),
            paymentPollIntervalProvider.overrideWithValue(null),
            paymentHoldTickIntervalProvider.overrideWithValue(null),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light(),
            locale: const Locale('en'),
            supportedLocales: AppLocales.supported,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: GoRouter(
              initialLocation: '/bookings/b-1',
              routes: [
                GoRoute(
                  path: '/bookings/:bookingId/payment',
                  builder:
                      (context, state) => PaymentScreen(
                        bookingId: state.pathParameters['bookingId'] ?? '',
                      ),
                ),
                GoRoute(
                  path: '/bookings/:bookingId',
                  builder:
                      (context, state) => BookingDetailScreen(
                        bookingId: state.pathParameters['bookingId'] ?? '',
                      ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(BookingDetailScreen)),
      );
      expect(find.text(l10n.myBookingsStatusPaymentRequired), findsWidgets);
      expect(find.text(l10n.bookingDetailShowPin), findsNothing);
      await tester.tap(find.text(l10n.myBookingsCompletePayment));
      await tester.pumpAndSettle();
      expect(find.byType(PaymentScreen), findsOneWidget);
      expect(bookings.createdOccurrenceIds, isEmpty);
    });
  });

  testWidgets('PENDING submitted shows waiting and View payment', (
    tester,
  ) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        bookings: FakeBookingsRemote(
          booking: _booking(
            status: 'PENDING',
            hasAccessPin: false,
            holdsUntil: DateTime.now().toUtc().add(const Duration(minutes: 10)),
            paymentSummary: const CustomerPaymentSummary(
              id: 'pay-1',
              status: 'SUBMITTED',
              method: 'CASH',
              amountSdg: 50000,
              currency: 'SDG',
              hasReceipt: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(BookingDetailScreen)),
    );
    expect(find.text(l10n.myBookingsStatusWaiting), findsWidgets);
    expect(find.text(l10n.bookingDetailWaitingBody), findsOneWidget);
    expect(find.text(l10n.myBookingsViewPayment), findsOneWidget);
    expect(find.text(l10n.myBookingsCompletePayment), findsNothing);
  });

  testWidgets('PENDING rejected shows retry payment', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        bookings: FakeBookingsRemote(
          booking: _booking(
            status: 'PENDING',
            hasAccessPin: false,
            holdsUntil: DateTime.now().toUtc().add(const Duration(minutes: 10)),
            paymentSummary: const CustomerPaymentSummary(
              id: 'pay-9',
              status: 'REJECTED',
              method: 'BANKAK',
              amountSdg: 50000,
              currency: 'SDG',
              hasReceipt: true,
              rejectionReason: 'Blurry image',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(BookingDetailScreen)),
    );
    expect(find.text(l10n.myBookingsStatusRejected), findsWidgets);
    expect(find.text('Blurry image'), findsOneWidget);
    expect(find.text(l10n.myBookingsRetryPayment), findsOneWidget);
  });

  testWidgets('CANCELLED EXPIRED COMPLETED have no PIN or payment action', (
    tester,
  ) async {
    await prepare(tester, const Size(390, 844));
    for (final status in ['CANCELLED', 'EXPIRED', 'COMPLETED']) {
      await tester.pumpWidget(
        _app(
          bookings: FakeBookingsRemote(
            booking: _booking(status: status, hasAccessPin: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(BookingDetailScreen)),
      );
      expect(find.text(l10n.bookingDetailShowPin), findsNothing);
      expect(find.text(l10n.myBookingsCompletePayment), findsNothing);
      expect(find.text(l10n.myBookingsRetryPayment), findsNothing);
      expect(find.text(l10n.myBookingsViewPayment), findsNothing);
    }
  });

  testWidgets('Arabic RTL keeps time and PIN digits LTR', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        bookings: FakeBookingsRemote(booking: _booking()),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(BookingDetailScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    final l10n = AppLocalizations.of(context);
    expect(find.text(l10n.myBookingsStatusConfirmed), findsWidgets);
    expect(find.text('20:00 → 21:30'), findsWidgets);
    await tester.ensureVisible(find.text(l10n.bookingDetailShowPin));
    await tester.tap(find.text(l10n.bookingDetailShowPin));
    await tester.pumpAndSettle();
    expect(find.text('8'), findsWidgets);
    expect(find.text('4'), findsWidgets);
  });

  testWidgets('320px and 390px confirmed booking do not overflow', (
    tester,
  ) async {
    for (final width in [320.0, 390.0]) {
      await prepare(tester, Size(width, 720));
      await tester.pumpWidget(
        _app(bookings: FakeBookingsRemote(booking: _booking())),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(BookingDetailScreen), findsOneWidget);
    }
  });
}
