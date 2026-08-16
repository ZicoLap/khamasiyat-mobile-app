import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/clock/app_clock.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/my_booking_face.dart';

enum MyBookingsStatus {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  empty,
  failure,
}

@immutable
class MyBookingsState {
  const MyBookingsState({
    required this.status,
    this.filter = MyBookingsFilter.all,
    this.items = const [],
    this.page = 0,
    this.limit = 20,
    this.total = 0,
    this.error,
    this.loadMoreError,
  });

  final MyBookingsStatus status;
  final MyBookingsFilter filter;
  final List<CustomerBooking> items;
  final int page;
  final int limit;
  final int total;
  final Object? error;
  final Object? loadMoreError;

  static const initial = MyBookingsState(status: MyBookingsStatus.initial);

  bool get hasMore => items.length < total;

  bool get isBusy =>
      status == MyBookingsStatus.loading ||
      status == MyBookingsStatus.refreshing ||
      status == MyBookingsStatus.loadingMore;

  MyBookingsState copyWith({
    MyBookingsStatus? status,
    MyBookingsFilter? filter,
    List<CustomerBooking>? items,
    int? page,
    int? limit,
    int? total,
    Object? error,
    Object? loadMoreError,
    bool clearError = false,
    bool clearLoadMoreError = false,
  }) {
    return MyBookingsState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      items: items ?? this.items,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      error: clearError ? null : (error ?? this.error),
      loadMoreError:
          clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }
}

/// Hold countdown tick. Override with `null` in tests to avoid perpetual timers.
final myBookingsHoldTickIntervalProvider = Provider<Duration?>((ref) {
  return const Duration(seconds: 1);
});

final myBookingsControllerProvider =
    StateNotifierProvider<MyBookingsController, MyBookingsState>((ref) {
      ref.keepAlive();
      final controller = MyBookingsController(
        bookings: ref.watch(bookingsRepositoryProvider),
        holdTickInterval: ref.watch(myBookingsHoldTickIntervalProvider),
        clock: ref.watch(appClockProvider),
      );
      unawaited(controller.loadInitial());
      return controller;
    });

class MyBookingsController extends StateNotifier<MyBookingsState>
    with WidgetsBindingObserver {
  MyBookingsController({
    required BookingsRepository bookings,
    Duration? holdTickInterval,
    Clock clock = const Clock(),
    this.pageSize = 20,
  }) : _bookings = bookings,
       _clock = clock,
       super(MyBookingsState.initial) {
    WidgetsBinding.instance.addObserver(this);
    if (holdTickInterval != null) {
      _holdTicker = Timer.periodic(holdTickInterval, (_) => _onHoldTick());
    }
  }

  final BookingsRepository _bookings;
  final Clock _clock;
  final int pageSize;

  Timer? _holdTicker;
  var _disposed = false;
  var _fetchInFlight = false;
  var _loadMoreInFlight = false;
  var _requestId = 0;
  final _expiryRefreshIds = <String>{};

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

  Future<void> loadInitial() async {
    if (state.status == MyBookingsStatus.loading) return;
    state = state.copyWith(
      status: MyBookingsStatus.loading,
      clearError: true,
      clearLoadMoreError: true,
    );
    await _fetchPage(page: 1, replace: true);
  }

  Future<void> refresh() async {
    if (state.status == MyBookingsStatus.refreshing ||
        state.status == MyBookingsStatus.loading) {
      return;
    }
    state = state.copyWith(
      status: MyBookingsStatus.refreshing,
      clearError: true,
      clearLoadMoreError: true,
    );
    await _fetchPage(page: 1, replace: true, isRefresh: true);
  }

  Future<void> refreshQuiet() async {
    if (_fetchInFlight || state.status == MyBookingsStatus.loading) return;
    await _fetchPage(page: 1, replace: true, quiet: true);
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        _loadMoreInFlight ||
        _fetchInFlight ||
        state.status == MyBookingsStatus.loading ||
        state.status == MyBookingsStatus.loadingMore ||
        state.status == MyBookingsStatus.refreshing) {
      return;
    }
    _loadMoreInFlight = true;
    state = state.copyWith(
      status: MyBookingsStatus.loadingMore,
      clearLoadMoreError: true,
    );
    try {
      await _fetchPage(page: state.page + 1, replace: false);
    } finally {
      _loadMoreInFlight = false;
    }
  }

  Future<void> retryLoadMore() => loadMore();

  Future<void> setFilter(MyBookingsFilter filter) async {
    if (filter == state.filter &&
        (state.status == MyBookingsStatus.loaded ||
            state.status == MyBookingsStatus.empty ||
            state.status == MyBookingsStatus.loading)) {
      return;
    }
    _expiryRefreshIds.clear();
    state = state.copyWith(
      filter: filter,
      status: MyBookingsStatus.loading,
      items: const [],
      page: 0,
      total: 0,
      clearError: true,
      clearLoadMoreError: true,
    );
    await _fetchPage(page: 1, replace: true);
  }

  Future<void> _fetchPage({
    required int page,
    required bool replace,
    bool isRefresh = false,
    bool quiet = false,
  }) async {
    if (_fetchInFlight && quiet) return;
    _fetchInFlight = true;
    final requestId = ++_requestId;
    try {
      final result = await _bookings.listBookings(
        page: page,
        limit: pageSize,
        status: state.filter.apiStatus,
      );
      if (_disposed || requestId != _requestId) return;
      final merged = replace ? result.items : [...state.items, ...result.items];
      state = state.copyWith(
        status:
            merged.isEmpty ? MyBookingsStatus.empty : MyBookingsStatus.loaded,
        items: merged,
        page: result.page,
        limit: result.limit,
        total: result.total,
        clearError: true,
        clearLoadMoreError: true,
      );
    } catch (error) {
      if (_disposed || requestId != _requestId) return;
      if (replace && state.items.isEmpty && !quiet) {
        state = state.copyWith(status: MyBookingsStatus.failure, error: error);
      } else if (replace && (isRefresh || quiet)) {
        state = state.copyWith(
          status:
              state.items.isEmpty
                  ? MyBookingsStatus.empty
                  : MyBookingsStatus.loaded,
          error: error,
        );
      } else {
        state = state.copyWith(
          status:
              state.items.isEmpty
                  ? MyBookingsStatus.empty
                  : MyBookingsStatus.loaded,
          loadMoreError: error,
        );
      }
    } finally {
      _fetchInFlight = false;
    }
  }

  void _onHoldTick() {
    if (_disposed) return;
    final now = _clock.now().toUtc();
    var anyHold = false;
    for (final booking in state.items) {
      if (!booking.isPending || booking.holdsUntil == null) continue;
      anyHold = true;
      if (booking.isHoldExpired(now: now) &&
          !_expiryRefreshIds.contains(booking.id)) {
        _expiryRefreshIds.add(booking.id);
        unawaited(refreshQuiet());
      }
    }
    if (anyHold) {
      state = state.copyWith();
    }
  }
}
