import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/payments/data/payments_repository.dart';
import 'package:khamasiyat_mobile_app/features/payments/domain/payment_attempt_keys.dart';
import 'package:khamasiyat_mobile_app/features/payments/domain/payment_models.dart';

enum PaymentUiPhase {
  loading,
  ready,
  requestingIntent,
  uploading,
  submittingPayment,
  submitted,
  rejected,
  confirmed,
  expired,
  failure,
}

@immutable
class PaymentViewState {
  const PaymentViewState({
    required this.phase,
    this.booking,
    this.methods = const [],
    this.selectedMethod,
    this.receipt,
    this.reference = '',
    this.payment,
    this.errorMessage,
    this.uploadProgress,
    this.remainingHold,
  });

  final PaymentUiPhase phase;
  final CustomerBooking? booking;
  final List<StadiumPaymentMethod> methods;
  final StadiumPaymentMethodType? selectedMethod;
  final SelectedReceiptFile? receipt;
  final String reference;
  final PaymentRecord? payment;
  final String? errorMessage;
  final double? uploadProgress;
  final Duration? remainingHold;

  bool get isBusy =>
      phase == PaymentUiPhase.loading ||
      phase == PaymentUiPhase.requestingIntent ||
      phase == PaymentUiPhase.uploading ||
      phase == PaymentUiPhase.submittingPayment;

  bool get canSubmit {
    if (isBusy) return false;
    if (phase == PaymentUiPhase.expired ||
        phase == PaymentUiPhase.confirmed ||
        phase == PaymentUiPhase.submitted) {
      return false;
    }
    final method = selectedMethod;
    if (method == null || booking == null) return false;
    if (method.requiresReceipt) {
      return receipt != null && reference.trim().isNotEmpty;
    }
    return true;
  }

  PaymentViewState copyWith({
    PaymentUiPhase? phase,
    CustomerBooking? booking,
    List<StadiumPaymentMethod>? methods,
    StadiumPaymentMethodType? selectedMethod,
    SelectedReceiptFile? receipt,
    String? reference,
    PaymentRecord? payment,
    String? errorMessage,
    double? uploadProgress,
    Duration? remainingHold,
    bool clearReceipt = false,
    bool clearError = false,
    bool clearSelectedMethod = false,
    bool clearPayment = false,
  }) {
    return PaymentViewState(
      phase: phase ?? this.phase,
      booking: booking ?? this.booking,
      methods: methods ?? this.methods,
      selectedMethod:
          clearSelectedMethod ? null : (selectedMethod ?? this.selectedMethod),
      receipt: clearReceipt ? null : (receipt ?? this.receipt),
      reference: reference ?? this.reference,
      payment: clearPayment ? null : (payment ?? this.payment),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      uploadProgress: uploadProgress,
      remainingHold: remainingHold ?? this.remainingHold,
    );
  }
}

final paymentPollIntervalProvider = Provider<Duration?>((ref) {
  return const Duration(seconds: 7);
});

/// Hold countdown tick. Override with `null` in tests to avoid perpetual timers.
final paymentHoldTickIntervalProvider = Provider<Duration?>((ref) {
  return const Duration(seconds: 1);
});

final paymentControllerProvider = StateNotifierProvider.autoDispose
    .family<PaymentController, PaymentViewState, String>((ref, bookingId) {
      return PaymentController(
        bookingId: bookingId,
        bookings: ref.watch(bookingsRepositoryProvider),
        payments: ref.watch(paymentsRepositoryProvider),
        pollInterval: ref.watch(paymentPollIntervalProvider),
        holdTickInterval: ref.watch(paymentHoldTickIntervalProvider),
      );
    });

class PaymentController extends StateNotifier<PaymentViewState>
    with WidgetsBindingObserver {
  PaymentController({
    required this.bookingId,
    required BookingsRepository bookings,
    required PaymentsRepository payments,
    Duration? pollInterval,
    Duration? holdTickInterval,
    PaymentAttemptKeys? attemptKeys,
  }) : _bookings = bookings,
       _payments = payments,
       _pollInterval = pollInterval,
       _attemptKeys = attemptKeys ?? PaymentAttemptKeys(),
       super(const PaymentViewState(phase: PaymentUiPhase.loading)) {
    WidgetsBinding.instance.addObserver(this);
    unawaited(load());
    if (holdTickInterval != null) {
      _holdTicker = Timer.periodic(holdTickInterval, (_) {
        _refreshHoldCountdown();
      });
    }
  }

  final String bookingId;
  final BookingsRepository _bookings;
  final PaymentsRepository _payments;
  final Duration? _pollInterval;
  final PaymentAttemptKeys _attemptKeys;

  Timer? _holdTicker;
  Timer? _pollTimer;
  var _disposed = false;
  var _foreground = true;
  var _submitInFlight = false;

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _holdTicker?.cancel();
    _stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      unawaited(refreshQuiet());
      _ensurePolling();
    } else {
      _stopPolling();
    }
  }

  Future<void> load() async {
    state = state.copyWith(
      phase: PaymentUiPhase.loading,
      clearError: true,
    );
    try {
      final booking = await _bookings.getBooking(bookingId);
      if (_disposed) return;
      await _applyBooking(booking, loadMethods: true);
    } on AppException catch (error) {
      if (_disposed) return;
      state = state.copyWith(
        phase: PaymentUiPhase.failure,
        errorMessage: error.message,
      );
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(
        phase: PaymentUiPhase.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshQuiet() async {
    try {
      final booking = await _bookings.getBooking(bookingId);
      if (_disposed) return;
      await _applyBooking(booking, loadMethods: state.methods.isEmpty);
    } catch (_) {
      // Quiet refresh — keep current UI.
    }
  }

  Future<void> _applyBooking(
    CustomerBooking booking, {
    required bool loadMethods,
  }) async {
    List<StadiumPaymentMethod> methods = state.methods;
    if (loadMethods && booking.stadiumId.isNotEmpty) {
      try {
        methods = await _payments.listStadiumPaymentMethods(booking.stadiumId);
      } catch (_) {
        // Keep previous methods if refresh of methods fails.
      }
    }

    PaymentRecord? payment = state.payment;
    final summary = booking.paymentSummary;
    if (summary != null) {
      try {
        payment = await _payments.getPayment(summary.id);
      } catch (_) {
        payment = PaymentRecord(
          id: summary.id,
          bookingId: booking.id,
          stadiumId: booking.stadiumId,
          method: StadiumPaymentMethodType.fromApi(summary.method),
          status: summary.status,
          amountSdg: summary.amountSdg,
          currency: summary.currency,
          hasReceipt: summary.hasReceipt,
          rejectionReason: summary.rejectionReason,
          submittedAt: summary.submittedAt,
          confirmedAt: summary.confirmedAt,
          rejectedAt: summary.rejectedAt,
        );
      }
    }

    final phase = _phaseFor(booking: booking, payment: payment);
    state = state.copyWith(
      phase: phase,
      booking: booking,
      methods: methods,
      payment: payment,
      remainingHold: _remaining(booking.holdsUntil),
      clearError: phase != PaymentUiPhase.failure,
    );
    _ensurePolling();
  }

  PaymentUiPhase _phaseFor({
    required CustomerBooking booking,
    PaymentRecord? payment,
  }) {
    if (booking.isExpired ||
        booking.isCancelled ||
        booking.isHoldExpired(now: clock.now().toUtc())) {
      return PaymentUiPhase.expired;
    }
    if (payment?.isConfirmed == true || booking.isConfirmed) {
      return PaymentUiPhase.confirmed;
    }
    if (payment?.isRejected == true) {
      return PaymentUiPhase.rejected;
    }
    if (payment?.isSubmitted == true) {
      return PaymentUiPhase.submitted;
    }
    return PaymentUiPhase.ready;
  }

  Duration? _remaining(DateTime? holdsUntil) {
    if (holdsUntil == null) return null;
    final left = holdsUntil.difference(clock.now().toUtc());
    if (left.isNegative) return Duration.zero;
    return left;
  }

  void _refreshHoldCountdown() {
    final booking = state.booking;
    if (booking == null) return;
    final remaining = _remaining(booking.holdsUntil);
    if (remaining == Duration.zero &&
        state.phase != PaymentUiPhase.expired &&
        state.phase != PaymentUiPhase.confirmed) {
      unawaited(refreshQuiet());
    }
    state = state.copyWith(remainingHold: remaining);
  }

  void selectMethod(StadiumPaymentMethodType method) {
    if (state.isBusy ||
        state.phase == PaymentUiPhase.submitted ||
        state.phase == PaymentUiPhase.confirmed ||
        state.phase == PaymentUiPhase.expired) {
      return;
    }
    _attemptKeys.reset();
    state = state.copyWith(
      selectedMethod: method,
      clearReceipt: true,
      reference: '',
      clearError: true,
      phase:
          state.phase == PaymentUiPhase.rejected
              ? PaymentUiPhase.ready
              : state.phase,
    );
  }

  void setReference(String value) {
    state = state.copyWith(reference: value, clearError: true);
  }

  void setReceipt(SelectedReceiptFile? file) {
    state = state.copyWith(
      receipt: file,
      clearReceipt: file == null,
      clearError: true,
    );
  }

  /// After REJECTED, allow another receipt/payment while the hold remains.
  void beginRetryAfterRejection() {
    if (state.phase != PaymentUiPhase.rejected) return;
    _attemptKeys.reset();
    state = state.copyWith(
      phase: PaymentUiPhase.ready,
      clearPayment: true,
      clearReceipt: true,
      reference: '',
      clearError: true,
    );
  }

  Future<void> submit() async {
    if (!state.canSubmit || _submitInFlight) return;
    final booking = state.booking!;
    final method = state.selectedMethod!;
    if (booking.isHoldExpired(now: clock.now().toUtc())) {
      state = state.copyWith(phase: PaymentUiPhase.expired);
      return;
    }

    _submitInFlight = true;
    try {
      if (method.requiresReceipt) {
        await _submitBank(booking, method);
      } else {
        await _submitCash(booking, method);
      }
    } on AppException catch (error) {
      if (_disposed) return;
      if (error is ApiException &&
          (error.code == 'PAYMENT_BOOKING_EXPIRED' ||
              error.code.contains('EXPIRED'))) {
        state = state.copyWith(
          phase: PaymentUiPhase.expired,
          uploadProgress: null,
        );
        return;
      }
      state = state.copyWith(
        phase: PaymentUiPhase.ready,
        errorMessage: error.message,
        uploadProgress: null,
      );
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(
        phase: PaymentUiPhase.ready,
        errorMessage: error.toString(),
        uploadProgress: null,
      );
    } finally {
      _submitInFlight = false;
    }
  }

  Future<void> _submitCash(
    CustomerBooking booking,
    StadiumPaymentMethodType method,
  ) async {
    state = state.copyWith(
      phase: PaymentUiPhase.submittingPayment,
      clearError: true,
    );
    final key = _attemptKeys.keyFor(
      bookingId: booking.id,
      method: method.apiValue,
    );
    final payment = await _payments.submitPayment(
      bookingId: booking.id,
      method: method.apiValue,
      idempotencyKey: key,
    );
    if (_disposed) return;
    state = state.copyWith(
      phase: PaymentUiPhase.submitted,
      payment: payment,
      uploadProgress: null,
    );
    _ensurePolling();
  }

  Future<void> _submitBank(
    CustomerBooking booking,
    StadiumPaymentMethodType method,
  ) async {
    final file = state.receipt!;
    if (!kReceiptAllowedContentTypes.contains(file.contentType)) {
      state = state.copyWith(
        errorMessage: 'unsupported_type',
        phase: PaymentUiPhase.ready,
      );
      return;
    }
    if (file.sizeBytes > kReceiptDefaultMaxBytes) {
      state = state.copyWith(
        errorMessage: 'oversized',
        phase: PaymentUiPhase.ready,
      );
      return;
    }

    state = state.copyWith(
      phase: PaymentUiPhase.requestingIntent,
      clearError: true,
      uploadProgress: 0,
    );
    final intent = await _payments.createReceiptUploadIntent(
      bookingId: booking.id,
      method: method.apiValue,
      contentType: file.contentType,
      sizeBytes: file.sizeBytes,
    );
    if (_disposed) return;

    state = state.copyWith(phase: PaymentUiPhase.uploading, uploadProgress: 0);
    final contentType =
        intent.headers['Content-Type'] ??
        intent.headers['content-type'] ??
        file.contentType;
    await _payments.uploadReceiptBytes(
      uploadUrl: intent.uploadUrl,
      bytes: file.bytes,
      contentType: contentType,
      onProgress: (sent, total) {
        if (_disposed || total <= 0) return;
        state = state.copyWith(
          phase: PaymentUiPhase.uploading,
          uploadProgress: sent / total,
        );
      },
    );
    if (_disposed) return;

    state = state.copyWith(
      phase: PaymentUiPhase.submittingPayment,
      uploadProgress: 1,
    );
    final key = _attemptKeys.keyFor(
      bookingId: booking.id,
      method: method.apiValue,
    );
    final payment = await _payments.submitPayment(
      bookingId: booking.id,
      method: method.apiValue,
      reference: state.reference.trim(),
      receiptUploadIntentId: intent.uploadIntentId,
      idempotencyKey: key,
    );
    if (_disposed) return;
    state = state.copyWith(
      phase: PaymentUiPhase.submitted,
      payment: payment,
      uploadProgress: null,
    );
    _ensurePolling();
  }

  void _ensurePolling() {
    final interval = _pollInterval;
    final shouldPoll =
        _foreground &&
        state.phase == PaymentUiPhase.submitted &&
        interval != null;
    if (!shouldPoll) {
      _stopPolling();
      return;
    }
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(interval, (_) {
      unawaited(refreshQuiet());
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}
