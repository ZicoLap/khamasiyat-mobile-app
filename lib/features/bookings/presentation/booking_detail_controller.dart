import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/clock/app_clock.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/my_booking_face.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/pitch_detail_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_detail_models.dart';

enum BookingDetailStatus { initial, loading, loaded, refreshing, failure }

@immutable
class BookingDetailState {
  const BookingDetailState({
    required this.status,
    this.booking,
    this.stadium,
    this.pitch,
    this.error,
    this.pin,
    this.pinVisible = false,
    this.pinLoading = false,
    this.pinError,
  });

  final BookingDetailStatus status;
  final CustomerBooking? booking;
  final StadiumDetail? stadium;
  final PitchDetail? pitch;
  final Object? error;
  final String? pin;
  final bool pinVisible;
  final bool pinLoading;
  final Object? pinError;

  static const initial = BookingDetailState(
    status: BookingDetailStatus.initial,
  );

  bool get offersPin {
    final current = booking;
    return current != null && bookingDetailOffersPin(current);
  }

  String? get heroPhotoUrl {
    final pitchPhotos = pitch?.photos;
    if (pitchPhotos != null && pitchPhotos.isNotEmpty) {
      return pitchPhotos.first.url;
    }
    final stadiumPhotos = stadium?.photos;
    if (stadiumPhotos != null && stadiumPhotos.isNotEmpty) {
      return stadiumPhotos.first.url;
    }
    return null;
  }

  BookingDetailState copyWith({
    BookingDetailStatus? status,
    CustomerBooking? booking,
    StadiumDetail? stadium,
    PitchDetail? pitch,
    Object? error,
    String? pin,
    bool? pinVisible,
    bool? pinLoading,
    Object? pinError,
    bool clearError = false,
    bool clearPin = false,
    bool clearPinError = false,
    bool clearVenue = false,
  }) {
    return BookingDetailState(
      status: status ?? this.status,
      booking: booking ?? this.booking,
      stadium: clearVenue ? stadium : (stadium ?? this.stadium),
      pitch: clearVenue ? pitch : (pitch ?? this.pitch),
      error: clearError ? null : (error ?? this.error),
      pin: clearPin ? null : (pin ?? this.pin),
      pinVisible: clearPin ? false : (pinVisible ?? this.pinVisible),
      pinLoading: pinLoading ?? this.pinLoading,
      pinError: clearPinError ? null : (pinError ?? this.pinError),
    );
  }

  @override
  String toString() =>
      'BookingDetailState(status: $status, pinVisible: $pinVisible, '
      'hasPin: ${pin != null}, pinLoading: $pinLoading)';
}

/// Hold countdown tick. Override with `null` in tests to avoid perpetual timers.
final bookingDetailHoldTickIntervalProvider = Provider<Duration?>((ref) {
  return const Duration(seconds: 1);
});

final bookingDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<BookingDetailController, BookingDetailState, String>((
      ref,
      bookingId,
    ) {
      final controller = BookingDetailController(
        bookingId: bookingId,
        bookings: ref.watch(bookingsRepositoryProvider),
        catalog: ref.watch(catalogRepositoryProvider),
        holdTickInterval: ref.watch(bookingDetailHoldTickIntervalProvider),
        clock: ref.watch(appClockProvider),
      );
      unawaited(controller.load());
      return controller;
    });

class BookingDetailController extends StateNotifier<BookingDetailState>
    with WidgetsBindingObserver {
  BookingDetailController({
    required this.bookingId,
    required BookingsRepository bookings,
    required CatalogRepository catalog,
    Duration? holdTickInterval,
    Clock clock = const Clock(),
  }) : _bookings = bookings,
       _catalog = catalog,
       _clock = clock,
       super(BookingDetailState.initial) {
    WidgetsBinding.instance.addObserver(this);
    if (holdTickInterval != null) {
      _holdTicker = Timer.periodic(holdTickInterval, (_) => _onHoldTick());
    }
  }

  final String bookingId;
  final BookingsRepository _bookings;
  final CatalogRepository _catalog;
  final Clock _clock;

  Timer? _holdTicker;
  var _disposed = false;
  var _fetchInFlight = false;
  var _pinInFlight = false;
  var _requestId = 0;
  var _holdExpiryRefreshArmed = false;

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _holdTicker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshQuiet());
    }
  }

  Future<void> load() async {
    if (state.status == BookingDetailStatus.loading) return;
    state = state.copyWith(
      status: BookingDetailStatus.loading,
      clearError: true,
    );
    await _fetchBooking();
  }

  Future<void> refresh() async {
    if (state.status == BookingDetailStatus.refreshing ||
        state.status == BookingDetailStatus.loading) {
      return;
    }
    state = state.copyWith(
      status: BookingDetailStatus.refreshing,
      clearError: true,
    );
    await _fetchBooking(isRefresh: true);
  }

  Future<void> refreshQuiet() async {
    if (_fetchInFlight || state.status == BookingDetailStatus.loading) return;
    await _fetchBooking(quiet: true);
  }

  Future<void> showPin() async {
    if (!state.offersPin) return;
    if (state.pin != null) {
      state = state.copyWith(pinVisible: true, clearPinError: true);
      return;
    }
    await _fetchPin();
  }

  void hidePin() {
    if (!state.pinVisible) return;
    state = state.copyWith(pinVisible: false);
  }

  Future<void> retryPin() => _fetchPin();

  Future<void> _fetchBooking({
    bool isRefresh = false,
    bool quiet = false,
  }) async {
    if (_fetchInFlight && quiet) return;
    _fetchInFlight = true;
    final requestId = ++_requestId;
    try {
      final booking = await _bookings.getBooking(bookingId);
      if (_disposed || requestId != _requestId) return;
      final keepPin = bookingDetailOffersPin(booking) && state.pin != null;
      state = state.copyWith(
        status: BookingDetailStatus.loaded,
        booking: booking,
        clearError: true,
        clearPin: !keepPin,
        clearPinError: !keepPin,
      );
      await _enrichVenue(requestId, booking);
    } catch (error) {
      if (_disposed || requestId != _requestId) return;
      if (state.booking == null && !quiet) {
        state = state.copyWith(
          status: BookingDetailStatus.failure,
          error: error,
        );
      } else {
        state = state.copyWith(
          status: BookingDetailStatus.loaded,
          error: (isRefresh || quiet) ? error : state.error,
        );
      }
    } finally {
      _fetchInFlight = false;
    }
  }

  Future<void> _enrichVenue(int requestId, CustomerBooking booking) async {
    StadiumDetail? stadium = state.stadium;
    PitchDetail? pitch = state.pitch;
    if (booking.stadiumId.isNotEmpty) {
      try {
        stadium = await _catalog.getStadium(booking.stadiumId);
      } catch (_) {
        // Venue extras are optional. Booking detail still works without them.
      }
    }
    if (booking.pitchId.isNotEmpty) {
      try {
        pitch = await _catalog.getPitch(booking.pitchId);
      } catch (_) {
        // Pitch extras are optional.
      }
    }
    if (_disposed || requestId != _requestId) return;
    state = state.copyWith(stadium: stadium, pitch: pitch);
  }

  Future<void> _fetchPin() async {
    if (!state.offersPin || _pinInFlight) return;
    _pinInFlight = true;
    state = state.copyWith(pinLoading: true, clearPinError: true);
    try {
      final result = await _bookings.getAccessPin(bookingId);
      if (_disposed) return;
      state = state.copyWith(
        pin: result.pin,
        pinVisible: true,
        pinLoading: false,
        clearPinError: true,
      );
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(
        pinLoading: false,
        pinError: error,
        pinVisible: false,
      );
    } finally {
      _pinInFlight = false;
    }
  }

  void _onHoldTick() {
    if (_disposed) return;
    final booking = state.booking;
    if (booking == null || !booking.isPending || booking.holdsUntil == null) {
      return;
    }
    final now = _clock.now().toUtc();
    if (booking.isHoldExpired(now: now) && !_holdExpiryRefreshArmed) {
      _holdExpiryRefreshArmed = true;
      unawaited(refreshQuiet());
    }
    state = state.copyWith();
  }
}
