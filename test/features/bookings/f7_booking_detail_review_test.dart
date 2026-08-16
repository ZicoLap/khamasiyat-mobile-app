import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_detail_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_detail_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';
import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

import '../../helpers/fake_bookings_remote.dart';
import '../../helpers/fake_catalog_remote.dart';
import '../../helpers/solid_color_image.dart';

/// F7 Booking Detail visual review — regenerate with:
/// `flutter test --update-goldens test/features/bookings/f7_booking_detail_review_test.dart`
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

  Widget frame({
    required FakeBookingsRemote bookings,
    Locale locale = const Locale('en'),
  }) {
    return RepaintBoundary(
      key: const ValueKey('detail-root'),
      child: ProviderScope(
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
          bookingDetailHoldTickIntervalProvider.overrideWithValue(null),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
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
      ),
    );
  }

  Future<void> golden(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('detail-root')),
      matchesGoldenFile('../../../docs/f7-visual-review/$name.png'),
    );
  }

  final hold = DateTime.utc(2026, 8, 15, 18, 12);

  testWidgets('1 en confirmed hidden PIN', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 17)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(bookings: FakeBookingsRemote(booking: _confirmed())),
      );
      await golden(tester, '01_en_confirmed_hidden_pin');
    });
  });

  testWidgets('2 en confirmed revealed PIN', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 17)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(bookings: FakeBookingsRemote(booking: _confirmed())),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Show PIN'));
      await tester.tap(find.text('Show PIN'));
      await golden(tester, '02_en_confirmed_revealed_pin');
    });
  });

  testWidgets('3 ar confirmed hidden PIN', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 17)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(
          locale: const Locale('ar'),
          bookings: FakeBookingsRemote(booking: _confirmed()),
        ),
      );
      await golden(tester, '03_ar_confirmed_hidden_pin');
    });
  });

  testWidgets('4 ar confirmed revealed PIN', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 17)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(
          locale: const Locale('ar'),
          bookings: FakeBookingsRemote(booking: _confirmed()),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(BookingDetailScreen)),
      );
      await tester.ensureVisible(find.text(l10n.bookingDetailShowPin));
      await tester.tap(find.text(l10n.bookingDetailShowPin));
      await golden(tester, '04_ar_confirmed_revealed_pin');
    });
  });

  testWidgets('5 pending payment required', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 18)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(
          bookings: FakeBookingsRemote(
            booking: _booking(
              status: 'PENDING',
              hasAccessPin: false,
              holdsUntil: hold,
            ),
          ),
        ),
      );
      await golden(tester, '05_pending_payment_required');
    });
  });

  testWidgets('6 pending payment submitted', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 18)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(
          bookings: FakeBookingsRemote(
            booking: _booking(
              status: 'PENDING',
              hasAccessPin: false,
              holdsUntil: hold,
              paymentSummary: const CustomerPaymentSummary(
                id: 'pay-1',
                status: 'SUBMITTED',
                method: 'CASH',
                amountSdg: 50000,
                currency: 'SDG',
                hasReceipt: false,
                submittedAt: null,
              ),
            ),
          ),
        ),
      );
      await golden(tester, '06_pending_payment_submitted');
    });
  });

  testWidgets('7 rejected payment', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 18)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(
          bookings: FakeBookingsRemote(
            booking: _booking(
              status: 'PENDING',
              hasAccessPin: false,
              holdsUntil: hold,
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
      await golden(tester, '07_rejected_payment');
    });
  });

  testWidgets('8 cancelled', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 18)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(
          bookings: FakeBookingsRemote(
            booking: _booking(status: 'CANCELLED', hasAccessPin: false),
          ),
        ),
      );
      await golden(tester, '08_cancelled');
    });
  });

  testWidgets('9 completed', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 16, 18)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(
          bookings: FakeBookingsRemote(
            booking: _booking(status: 'COMPLETED', hasAccessPin: false),
          ),
        ),
      );
      await golden(tester, '09_completed');
    });
  });

  testWidgets('10 expired', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 18)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(
          bookings: FakeBookingsRemote(
            booking: _booking(status: 'EXPIRED', hasAccessPin: false),
          ),
        ),
      );
      await golden(tester, '10_expired');
    });
  });

  testWidgets('11 320px confirmed booking', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 17)), () async {
      await prepare(tester, const Size(320, 720));
      await tester.pumpWidget(
        frame(bookings: FakeBookingsRemote(booking: _confirmed())),
      );
      await golden(tester, '11_320_confirmed');
    });
  });

  testWidgets('12 PIN error state', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 8, 15, 17)), () async {
      await prepare(tester, const Size(390, 844));
      await tester.pumpWidget(
        frame(
          bookings: FakeBookingsRemote(
            booking: _confirmed(),
            failAccessPinWith: const NetworkException(message: 'offline'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Show PIN'));
      await tester.tap(find.text('Show PIN'));
      await golden(tester, '12_pin_error');
    });
  });
}

CustomerBooking _confirmed() {
  return _booking(
    paymentSummary: const CustomerPaymentSummary(
      id: 'pay-1',
      status: 'CONFIRMED',
      method: 'BANKAK',
      amountSdg: 50000,
      currency: 'SDG',
      hasReceipt: true,
    ),
  );
}

CustomerBooking _booking({
  String status = 'CONFIRMED',
  bool hasAccessPin = true,
  DateTime? holdsUntil,
  CustomerPaymentSummary? paymentSummary,
}) {
  return CustomerBooking(
    id: 'b-1',
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
