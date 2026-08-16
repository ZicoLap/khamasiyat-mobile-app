import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_detail_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_detail_screen.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/my_bookings_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/my_bookings_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/payments/data/payments_repository.dart';
import 'package:khamasiyat_mobile_app/features/payments/presentation/payment_controller.dart';
import 'package:khamasiyat_mobile_app/features/payments/presentation/payment_screen.dart';
import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

import '../../helpers/fake_bookings_remote.dart';
import '../../helpers/fake_catalog_remote.dart';
import '../../helpers/fake_payments_remote.dart';

CustomerBooking _booking({
  String id = 'b-1',
  String status = 'PENDING',
  DateTime? holdsUntil,
  CustomerPaymentSummary? paymentSummary,
  String stadiumName = 'Al-Nile Stadium',
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
    stadiumName: stadiumName,
    pitchName: 'Pitch A',
    pitchType: PitchType.fiveASide,
    hasAccessPin: status == 'CONFIRMED',
    holdsUntil:
        holdsUntil ?? DateTime.now().toUtc().add(const Duration(minutes: 12)),
    paymentSummary: paymentSummary,
  );
}

List<Override> _overrides(FakeBookingsRemote bookings) {
  return [
    bookingsRepositoryProvider.overrideWithValue(BookingsRepository(bookings)),
    paymentsRepositoryProvider.overrideWithValue(
      PaymentsRepository(FakePaymentsRemote(), FakeReceiptUploadClient()),
    ),
    myBookingsHoldTickIntervalProvider.overrideWithValue(null),
    bookingDetailHoldTickIntervalProvider.overrideWithValue(null),
    catalogRepositoryProvider.overrideWithValue(
      CatalogRepository(
        FakeCatalogRemote(
          stadiumById: {'st1': sampleStadiumDetail(id: 'st1')},
          pitchById: {'p1': samplePitchDetail()},
        ),
      ),
    ),
    paymentPollIntervalProvider.overrideWithValue(null),
    paymentHoldTickIntervalProvider.overrideWithValue(null),
  ];
}

Widget _app({
  required FakeBookingsRemote bookings,
  Locale locale = const Locale('en'),
  String initialLocation = '/bookings',
}) {
  return ProviderScope(
    overrides: _overrides(bookings),
    child: MaterialApp.router(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/search',
            builder: (_, __) => const Scaffold(body: Text('Search tab')),
          ),
          GoRoute(
            path: '/bookings',
            builder: (_, __) => const MyBookingsScreen(),
          ),
          GoRoute(
            path: '/bookings/:bookingId/payment',
            builder: (context, state) {
              return PaymentScreen(
                bookingId: state.pathParameters['bookingId'] ?? '',
              );
            },
          ),
          GoRoute(
            path: '/bookings/:bookingId',
            builder: (context, state) {
              return BookingDetailScreen(
                bookingId: state.pathParameters['bookingId'] ?? '',
              );
            },
          ),
        ],
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loading shows booking-card skeletons', (tester) async {
    final bookings = FakeBookingsRemote(
      delay: const Duration(milliseconds: 80),
      listItems: [_booking()],
    );
    await tester.pumpWidget(_app(bookings: bookings));
    await tester.pump();
    expect(find.byType(MyBookingsSkeletonList), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('empty state offers Find a pitch', (tester) async {
    await tester.pumpWidget(_app(bookings: FakeBookingsRemote()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(MyBookingsScreen)),
    );
    expect(find.text(l10n.myBookingsEmptyTitle), findsOneWidget);
    expect(find.text(l10n.myBookingsEmptyBody), findsOneWidget);
    await tester.tap(find.text(l10n.myBookingsFindPitch));
    await tester.pumpAndSettle();
    expect(find.text('Search tab'), findsOneWidget);
  });

  testWidgets('error state offers retry', (tester) async {
    await tester.pumpWidget(
      _app(
        bookings: FakeBookingsRemote(
          failListWith: const NetworkException(message: 'offline'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(MyBookingsScreen)),
    );
    expect(find.text(l10n.myBookingsLoadFailed), findsOneWidget);
    expect(find.text(l10n.myBookingsTryAgain), findsOneWidget);
  });

  testWidgets('Complete payment opens existing booking payment route', (
    tester,
  ) async {
    final bookings = FakeBookingsRemote(
      booking: _booking(),
      listItems: [_booking()],
    );
    await tester.pumpWidget(_app(bookings: bookings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(MyBookingsScreen)),
    );
    expect(find.text(l10n.myBookingsStatusPaymentRequired), findsOneWidget);
    await tester.tap(find.text(l10n.myBookingsCompletePayment));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentScreen), findsOneWidget);
    expect(bookings.createdOccurrenceIds, isEmpty);
    expect(bookings.getBookingIds, contains('b-1'));
  });

  testWidgets('SUBMITTED card opens waiting payment state', (tester) async {
    final booking = _booking(
      paymentSummary: const CustomerPaymentSummary(
        id: 'pay-1',
        status: 'SUBMITTED',
        method: 'CASH',
        amountSdg: 15000,
        currency: 'SDG',
        hasReceipt: false,
      ),
    );
    final bookings = FakeBookingsRemote(booking: booking, listItems: [booking]);
    await tester.pumpWidget(_app(bookings: bookings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(MyBookingsScreen)),
    );
    expect(find.text(l10n.myBookingsStatusWaiting), findsOneWidget);
    expect(find.text(l10n.myBookingsCompletePayment), findsNothing);
    await tester.tap(find.text(l10n.myBookingsViewPayment));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentScreen), findsOneWidget);
    expect(find.text(l10n.paymentSubmittedTitle), findsOneWidget);
  });

  testWidgets('REJECTED retry payment opens same booking payment', (
    tester,
  ) async {
    final booking = _booking(
      paymentSummary: const CustomerPaymentSummary(
        id: 'pay-9',
        status: 'REJECTED',
        method: 'BANKAK',
        amountSdg: 15000,
        currency: 'SDG',
        hasReceipt: true,
        rejectionReason: 'Blurry',
      ),
    );
    final bookings = FakeBookingsRemote(booking: booking, listItems: [booking]);
    await tester.pumpWidget(_app(bookings: bookings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(MyBookingsScreen)),
    );
    expect(find.text(l10n.myBookingsStatusRejected), findsOneWidget);
    await tester.ensureVisible(find.text(l10n.myBookingsRetryPayment));
    await tester.tap(find.text(l10n.myBookingsRetryPayment));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentScreen), findsOneWidget);
    expect(bookings.createdOccurrenceIds, isEmpty);
  });

  testWidgets('CONFIRMED card tap opens Booking Detail with PIN', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final booking = _booking(status: 'CONFIRMED');
    final bookings = FakeBookingsRemote(booking: booking, listItems: [booking]);
    await tester.pumpWidget(_app(bookings: bookings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(MyBookingsScreen)),
    );
    expect(find.text(l10n.myBookingsStatusConfirmed), findsWidgets);
    expect(find.text(l10n.myBookingsViewBooking), findsNothing);
    await tester.tap(find.byType(MyBookingCard));
    await tester.pumpAndSettle();
    expect(find.byType(BookingDetailScreen), findsOneWidget);
    expect(find.text(l10n.bookingDetailShowPin), findsOneWidget);
    expect(find.text(l10n.myBookingsCompletePayment), findsNothing);
  });

  testWidgets('All groups upcoming and past bookings', (tester) async {
    await tester.pumpWidget(
      _app(
        bookings: FakeBookingsRemote(
          listItems: [
            _booking(id: 'b-up', status: 'CONFIRMED'),
            _booking(id: 'b-past', status: 'COMPLETED'),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(MyBookingsScreen)),
    );
    expect(find.text(l10n.myBookingsUpcoming), findsOneWidget);
    expect(find.text(l10n.myBookingsPast), findsOneWidget);
    expect(find.byType(MyBookingCard), findsNWidgets(2));
  });

  testWidgets('Arabic RTL list shows mapped status and LTR time range', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        bookings: FakeBookingsRemote(listItems: [_booking()]),
        locale: const Locale('ar'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final context = tester.element(find.byType(MyBookingsScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    final l10n = AppLocalizations.of(context);
    expect(find.text(l10n.myBookingsStatusPaymentRequired), findsOneWidget);
    expect(find.text(l10n.myBookingsCompletePayment), findsOneWidget);
    expect(find.text('08:00 → 09:00'), findsOneWidget);
  });

  testWidgets('320px and 390px cards do not overflow', (tester) async {
    for (final width in [320.0, 390.0]) {
      tester.view.physicalSize = Size(width, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _app(bookings: FakeBookingsRemote(listItems: [_booking()])),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      expect(find.byType(MyBookingCard), findsOneWidget);
    }
  });

  testWidgets('bottom navigation destinations remain on bookings list', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(FakeBookingsRemote(listItems: [_booking()])),
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: const MyBookingsScreen(),
            bottomNavigationBar: NavigationBar(
              selectedIndex: 2,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_note),
                  label: 'Bookings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Bookings'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(MyBookingsScreen), findsOneWidget);
  });
}
