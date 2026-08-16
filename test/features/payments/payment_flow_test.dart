import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/errors/api_error.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/payments/data/payments_repository.dart';
import 'package:khamasiyat_mobile_app/features/payments/domain/payment_attempt_keys.dart';
import 'package:khamasiyat_mobile_app/features/payments/domain/payment_models.dart';
import 'package:khamasiyat_mobile_app/features/payments/presentation/payment_controller.dart';
import 'package:khamasiyat_mobile_app/features/payments/presentation/payment_screen.dart';
import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

import '../../helpers/fake_bookings_remote.dart';
import '../../helpers/fake_payments_remote.dart';

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
    stadiumName: 'Green Field',
    pitchName: 'Pitch A',
    pitchType: PitchType.fiveASide,
    holdsUntil:
        holdsUntil ?? clock.now().toUtc().add(const Duration(minutes: 15)),
    paymentSummary: paymentSummary,
  );
}

SelectedReceiptFile _receipt({
  String name = 'receipt.jpg',
  String contentType = 'image/jpeg',
  int size = 100,
}) {
  return SelectedReceiptFile(
    name: name,
    bytes: List<int>.filled(size, 1),
    contentType: contentType,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PaymentAttemptKeys', () {
    test('reuses key for same booking+method and resets on change', () {
      var n = 0;
      final keys = PaymentAttemptKeys(createKey: () => 'k${++n}');
      expect(keys.keyFor(bookingId: 'b1', method: 'CASH'), 'k1');
      expect(keys.keyFor(bookingId: 'b1', method: 'CASH'), 'k1');
      expect(keys.keyFor(bookingId: 'b1', method: 'BANKAK'), 'k2');
      keys.reset();
      expect(keys.keyFor(bookingId: 'b1', method: 'BANKAK'), 'k3');
    });
  });

  group('receipt validation', () {
    test('accepts jpeg png webp pdf mime types', () {
      for (final type in [
        'image/jpeg',
        'image/png',
        'image/webp',
        'application/pdf',
      ]) {
        expect(kReceiptAllowedContentTypes.contains(type), isTrue);
      }
    });

    test('rejects invalid type and oversized size constants', () {
      expect(kReceiptAllowedContentTypes.contains('image/gif'), isFalse);
      expect(kReceiptDefaultMaxBytes, 5 * 1024 * 1024);
    });
  });

  group('hold countdown', () {
    test('formatHoldCountdown uses remaining duration only', () {
      expect(formatHoldCountdown(const Duration(minutes: 12, seconds: 48)), '12:48');
      expect(formatHoldCountdown(Duration.zero), '00:00');
      expect(formatHoldCountdown(null), '--:--');
    });

    test('remaining hold is holdsUntil - now and not reset on reopen', () {
      final holdsUntil = DateTime.utc(2026, 8, 14, 8, 12, 48);
      withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 8, 0)), () {
        final first = holdsUntil.difference(clock.now().toUtc());
        expect(first, const Duration(minutes: 12, seconds: 48));
      });
      withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 8, 5)), () {
        final second = holdsUntil.difference(clock.now().toUtc());
        expect(second, const Duration(minutes: 7, seconds: 48));
        expect(second.inMinutes, isNot(15));
      });
    });
  });

  group('PaymentController', () {
    late FakeBookingsRemote bookingsRemote;
    late FakePaymentsRemote paymentsRemote;
    late FakeReceiptUploadClient uploadClient;
    late ProviderContainer container;
    late ProviderSubscription<PaymentViewState> subscription;

    PaymentController controller() =>
        container.read(paymentControllerProvider('b-1').notifier);

    PaymentViewState state() =>
        container.read(paymentControllerProvider('b-1'));

    Future<void> waitReady() async {
      for (var i = 0; i < 100; i++) {
        final phase = container.read(paymentControllerProvider('b-1')).phase;
        if (phase != PaymentUiPhase.loading) return;
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      fail('PaymentController stayed in loading');
    }

    void bindContainer(ProviderContainer next) {
      container = next;
      subscription = container.listen(
        paymentControllerProvider('b-1'),
        (_, __) {},
        fireImmediately: true,
      );
    }

    setUp(() {
      bookingsRemote = FakeBookingsRemote(
        booking: _booking(),
      );
      paymentsRemote = FakePaymentsRemote();
      uploadClient = FakeReceiptUploadClient();
      bindContainer(
        ProviderContainer(
          overrides: [
            bookingsRepositoryProvider.overrideWithValue(
              BookingsRepository(bookingsRemote),
            ),
            paymentsRepositoryProvider.overrideWithValue(
              PaymentsRepository(paymentsRemote, uploadClient),
            ),
            paymentPollIntervalProvider.overrideWithValue(null),
            paymentHoldTickIntervalProvider.overrideWithValue(null),
          ],
        ),
      );
    });

    tearDown(() {
      subscription.close();
      container.dispose();
    });

    test('loads payment methods from backend', () async {
      await waitReady();
      expect(state().phase, PaymentUiPhase.ready);
      expect(state().methods.map((m) => m.method.apiValue), [
        'CASH',
        'BANKAK',
        'BANK_TRANSFER',
      ]);
      expect(bookingsRemote.getBookingIds, ['b-1']);
    });

    test('method selection updates state', () async {
      await waitReady();
      controller().selectMethod(StadiumPaymentMethodType.bankak);
      expect(state().selectedMethod, StadiumPaymentMethodType.bankak);
    });

    test('CASH skips receipt intent and submits method only', () async {
      await waitReady();
      controller().selectMethod(StadiumPaymentMethodType.cash);
      await controller().submit();
      expect(paymentsRemote.intentRequests, isEmpty);
      expect(uploadClient.putCalls, 0);
      expect(paymentsRemote.submitRequests, hasLength(1));
      final req = paymentsRemote.submitRequests.single;
      expect(req['method'], 'CASH');
      expect(req['receiptUploadIntentId'], isNull);
      expect(req.containsKey('amount'), isFalse);
      expect(req.containsKey('storageKey'), isFalse);
      expect(req['idempotencyKey'], isNotNull);
      expect(state().phase, PaymentUiPhase.submitted);
    });

    test('BANKAK requires receipt and reference then uploads', () async {
      await waitReady();
      controller().selectMethod(StadiumPaymentMethodType.bankak);
      expect(state().canSubmit, isFalse);
      controller().setReference('REF-99');
      controller().setReceipt(_receipt());
      expect(state().canSubmit, isTrue);
      await controller().submit();
      expect(paymentsRemote.intentRequests.single['method'], 'BANKAK');
      expect(paymentsRemote.intentRequests.single.containsKey('storageKey'), isFalse);
      expect(uploadClient.putCalls, 1);
      expect(uploadClient.puts.single['contentType'], 'image/jpeg');
      final submit = paymentsRemote.submitRequests.single;
      expect(submit['receiptUploadIntentId'], 'intent-1');
      expect(submit['reference'], 'REF-99');
      expect(submit.containsKey('amount'), isFalse);
      expect(submit.containsKey('storageKey'), isFalse);
      expect(state().phase, PaymentUiPhase.submitted);
    });

    test('BANK_TRANSFER requires receipt like BANKAK', () async {
      await waitReady();
      controller().selectMethod(StadiumPaymentMethodType.bankTransfer);
      controller().setReference('TR-1');
      controller().setReceipt(_receipt(name: 'r.png', contentType: 'image/png'));
      await controller().submit();
      expect(paymentsRemote.intentRequests.single['method'], 'BANK_TRANSFER');
      expect(paymentsRemote.intentRequests.single['contentType'], 'image/png');
    });

    test('accepts webp and pdf content types through intent', () async {
      for (final entry in [
        ('a.webp', 'image/webp'),
        ('a.pdf', 'application/pdf'),
      ]) {
        container.dispose();
        paymentsRemote = FakePaymentsRemote();
        uploadClient = FakeReceiptUploadClient();
        subscription.close();
        bindContainer(
          ProviderContainer(
            overrides: [
              bookingsRepositoryProvider.overrideWithValue(
                BookingsRepository(bookingsRemote),
              ),
              paymentsRepositoryProvider.overrideWithValue(
                PaymentsRepository(paymentsRemote, uploadClient),
              ),
              paymentPollIntervalProvider.overrideWithValue(null),
              paymentHoldTickIntervalProvider.overrideWithValue(null),
            ],
          ),
        );
        await waitReady();
        controller().selectMethod(StadiumPaymentMethodType.bankak);
        controller().setReference('R');
        controller().setReceipt(
          _receipt(name: entry.$1, contentType: entry.$2),
        );
        await controller().submit();
        expect(paymentsRemote.intentRequests.single['contentType'], entry.$2);
      }
    });

    test('invalid type handled without upload', () async {
      await waitReady();
      controller().selectMethod(StadiumPaymentMethodType.bankak);
      controller().setReference('R');
      controller().setReceipt(
        _receipt(name: 'x.gif', contentType: 'image/gif'),
      );
      await controller().submit();
      expect(paymentsRemote.intentRequests, isEmpty);
      expect(uploadClient.putCalls, 0);
      expect(state().errorMessage, 'unsupported_type');
    });

    test('oversized file handled without upload', () async {
      await waitReady();
      controller().selectMethod(StadiumPaymentMethodType.bankak);
      controller().setReference('R');
      controller().setReceipt(
        _receipt(size: kReceiptDefaultMaxBytes + 1),
      );
      await controller().submit();
      expect(paymentsRemote.intentRequests, isEmpty);
      expect(state().errorMessage, 'oversized');
    });

    test('PUT failure blocks payment submit', () async {
      uploadClient.failWith = const NetworkException(message: 'put failed');
      await waitReady();
      controller().selectMethod(StadiumPaymentMethodType.bankak);
      controller().setReference('R');
      controller().setReceipt(_receipt());
      await controller().submit();
      expect(uploadClient.putCalls, 1);
      expect(paymentsRemote.submitRequests, isEmpty);
      expect(state().phase, PaymentUiPhase.ready);
      expect(state().receipt, isNotNull);
    });

    test('duplicate submission blocked while in flight', () async {
      paymentsRemote = FakePaymentsRemote();
      final slow = _SlowPaymentsRemote(paymentsRemote);
      container.dispose();
      subscription.close();
      bindContainer(
        ProviderContainer(
          overrides: [
            bookingsRepositoryProvider.overrideWithValue(
              BookingsRepository(bookingsRemote),
            ),
            paymentsRepositoryProvider.overrideWithValue(
              PaymentsRepository(slow, uploadClient),
            ),
            paymentPollIntervalProvider.overrideWithValue(null),
            paymentHoldTickIntervalProvider.overrideWithValue(null),
          ],
        ),
      );
      await waitReady();
      controller().selectMethod(StadiumPaymentMethodType.cash);
      final first = controller().submit();
      final second = controller().submit();
      await Future.wait([first, second]);
      expect(slow.submitCalls, 1);
    });

    test('booking expiry disables payment', () async {
      bookingsRemote.booking = _booking(
        status: 'EXPIRED',
        holdsUntil: DateTime.utc(2026, 8, 14, 7, 0),
      );
      await controller().load();
      await waitReady();
      expect(state().phase, PaymentUiPhase.expired);
      controller().selectMethod(StadiumPaymentMethodType.cash);
      expect(state().canSubmit, isFalse);
    });

    test('hold expiry from holdsUntil marks expired on refresh', () async {
      final past = DateTime.utc(2026, 8, 14, 7, 0);
      bookingsRemote.booking = _booking(holdsUntil: past);
      await withClock(Clock.fixed(DateTime.utc(2026, 8, 14, 8, 0)), () async {
        await controller().load();
        await waitReady();
        expect(state().phase, PaymentUiPhase.expired);
      });
    });

    test('REJECTED shows rejectionReason and allows retry', () async {
      bookingsRemote.booking = _booking(
        paymentSummary: const CustomerPaymentSummary(
          id: 'pay-9',
          status: 'REJECTED',
          method: 'BANKAK',
          amountSdg: 15000,
          currency: 'SDG',
          hasReceipt: true,
          rejectionReason: 'Blurry image',
        ),
      );
      paymentsRemote.getPaymentResult = const PaymentRecord(
        id: 'pay-9',
        bookingId: 'b-1',
        stadiumId: 'st1',
        method: StadiumPaymentMethodType.bankak,
        status: 'REJECTED',
        amountSdg: 15000,
        currency: 'SDG',
        hasReceipt: true,
        rejectionReason: 'Blurry image',
      );
      await controller().load();
      await waitReady();
      expect(state().phase, PaymentUiPhase.rejected);
      expect(state().payment?.rejectionReason, 'Blurry image');
      controller().beginRetryAfterRejection();
      expect(state().phase, PaymentUiPhase.ready);
      expect(state().payment, isNull);
      controller().selectMethod(StadiumPaymentMethodType.bankak);
      controller().setReference('NEW');
      controller().setReceipt(_receipt());
      await controller().submit();
      expect(state().phase, PaymentUiPhase.submitted);
    });

    test('CONFIRMED state from payment', () async {
      bookingsRemote.booking = _booking(
        status: 'CONFIRMED',
        paymentSummary: const CustomerPaymentSummary(
          id: 'pay-2',
          status: 'CONFIRMED',
          method: 'CASH',
          amountSdg: 15000,
          currency: 'SDG',
          hasReceipt: false,
        ),
      );
      paymentsRemote.getPaymentResult = const PaymentRecord(
        id: 'pay-2',
        bookingId: 'b-1',
        stadiumId: 'st1',
        method: StadiumPaymentMethodType.cash,
        status: 'CONFIRMED',
        amountSdg: 15000,
        currency: 'SDG',
        hasReceipt: false,
      );
      await controller().load();
      await waitReady();
      expect(state().phase, PaymentUiPhase.confirmed);
    });

    test('SUBMITTED polling refreshes payment quietly', () async {
      container.dispose();
      subscription.close();
      bindContainer(
        ProviderContainer(
          overrides: [
            bookingsRepositoryProvider.overrideWithValue(
              BookingsRepository(bookingsRemote),
            ),
            paymentsRepositoryProvider.overrideWithValue(
              PaymentsRepository(paymentsRemote, uploadClient),
            ),
            paymentPollIntervalProvider.overrideWithValue(
              const Duration(milliseconds: 40),
            ),
            paymentHoldTickIntervalProvider.overrideWithValue(null),
          ],
        ),
      );
      await waitReady();
      controller().selectMethod(StadiumPaymentMethodType.cash);
      await controller().submit();
      expect(state().phase, PaymentUiPhase.submitted);
      final before = bookingsRemote.getBookingIds.length;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(bookingsRemote.getBookingIds.length, greaterThan(before));
    });

    test('app resume refetches', () async {
      await waitReady();
      final before = bookingsRemote.getBookingIds.length;
      controller().didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bookingsRemote.getBookingIds.length, greaterThan(before));
    });

    test('expired booking during submit maps to expired', () async {
      paymentsRemote.failSubmitWith = ApiException(
        error: const ApiError(
          code: 'PAYMENT_BOOKING_EXPIRED',
          message: 'Hold ended',
        ),
      );
      await waitReady();
      controller().selectMethod(StadiumPaymentMethodType.cash);
      await controller().submit();
      expect(state().phase, PaymentUiPhase.expired);
    });
  });

  group('PaymentScreen UI', () {
    testWidgets('Arabic RTL shows reserved hold title', (tester) async {
      final bookingsRemote = FakeBookingsRemote(booking: _booking());
      final paymentsRemote = FakePaymentsRemote();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingsRepositoryProvider.overrideWithValue(
              BookingsRepository(bookingsRemote),
            ),
            paymentsRepositoryProvider.overrideWithValue(
              PaymentsRepository(paymentsRemote, FakeReceiptUploadClient()),
            ),
            paymentPollIntervalProvider.overrideWithValue(null),
            paymentHoldTickIntervalProvider.overrideWithValue(null),
          ],
          child: const MaterialApp(
            locale: Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: PaymentScreen(bookingId: 'b-1'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final context = tester.element(find.byType(PaymentScreen));
      expect(Directionality.of(context), TextDirection.rtl);
      final l10n = AppLocalizations.of(context);
      expect(find.text(l10n.paymentHoldReservedTitle), findsOneWidget);
      expect(find.text(l10n.paymentChooseMethod), findsOneWidget);
    });
  });
}

class _SlowPaymentsRemote implements PaymentsRemoteSource {
  _SlowPaymentsRemote(this._inner);

  final FakePaymentsRemote _inner;
  int submitCalls = 0;

  @override
  Future<ReceiptUploadIntent> createReceiptUploadIntent({
    required String bookingId,
    required String method,
    required String contentType,
    required int sizeBytes,
  }) =>
      _inner.createReceiptUploadIntent(
        bookingId: bookingId,
        method: method,
        contentType: contentType,
        sizeBytes: sizeBytes,
      );

  @override
  Future<PaymentRecord> getPayment(String paymentId) =>
      _inner.getPayment(paymentId);

  @override
  Future<List<PaymentRecord>> listBookingPayments(String bookingId) =>
      _inner.listBookingPayments(bookingId);

  @override
  Future<List<StadiumPaymentMethod>> listStadiumPaymentMethods(
    String stadiumId,
  ) =>
      _inner.listStadiumPaymentMethods(stadiumId);

  @override
  Future<PaymentRecord> submitPayment({
    required String bookingId,
    required String method,
    String? reference,
    String? receiptUploadIntentId,
    String? idempotencyKey,
  }) async {
    submitCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _inner.submitPayment(
      bookingId: bookingId,
      method: method,
      reference: reference,
      receiptUploadIntentId: receiptUploadIntentId,
      idempotencyKey: idempotencyKey,
    );
  }
}
