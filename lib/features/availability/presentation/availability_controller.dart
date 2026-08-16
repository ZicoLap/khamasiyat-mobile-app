import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/features/availability/data/availability_repository.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/availability_models.dart';

/// `null` disables polling (widget tests that call [pumpAndSettle]).
final availabilityPollIntervalProvider = Provider<Duration?>((ref) {
  return const Duration(seconds: 25);
});

final pitchAvailabilityProvider = AsyncNotifierProvider.autoDispose
    .family<PitchAvailabilityNotifier, PitchAvailability, AvailabilityQuery>(
      PitchAvailabilityNotifier.new,
    );

class PitchAvailabilityNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<PitchAvailability, AvailabilityQuery> {
  Timer? _poll;
  Future<void>? _inFlight;
  var _refreshQueued = false;
  var _foreground = true;
  var _disposed = false;

  bool get hasInFlightRequest => _inFlight != null;

  @override
  Future<PitchAvailability> build(AvailabilityQuery query) async {
    _disposed = false;
    _foreground = true;
    ref.onDispose(() {
      _disposed = true;
      _stopPolling();
    });
    final data = await _fetch();
    if (!_disposed) {
      _syncPolling();
    }
    return data;
  }

  Future<void> retry() async {
    if (state.hasValue) {
      await refreshQuiet();
      return;
    }
    state = const AsyncLoading();
    try {
      final data = await _fetch();
      if (_disposed) return;
      state = AsyncData(data);
      _syncPolling();
    } catch (error, stack) {
      if (_disposed) return;
      state = AsyncError(error, stack);
    }
  }

  /// Pull-to-refresh, resume, polling, SSE hints, and 409 recovery.
  /// Keeps the last good list if the request fails.
  Future<void> refreshQuiet({bool queueIfBusy = false}) {
    final existing = _inFlight;
    if (existing != null) {
      if (queueIfBusy) {
        _refreshQueued = true;
      }
      return existing;
    }
    final future = _drainRefresh();
    _inFlight = future;
    unawaited(
      future.whenComplete(() {
        if (identical(_inFlight, future)) {
          _inFlight = null;
        }
      }),
    );
    return future;
  }

  void setForeground(bool foreground) {
    if (_disposed) return;
    final wasForeground = _foreground;
    _foreground = foreground;
    _syncPolling();
    if (foreground && !wasForeground) {
      unawaited(refreshQuiet());
    }
  }

  /// Apply pause/resume without treating first alignment as an app resume.
  void alignForeground(bool foreground) {
    if (_disposed) return;
    if (_foreground == foreground) return;
    _foreground = foreground;
    _syncPolling();
  }

  Future<PitchAvailability> _fetch() {
    return ref.read(availabilityRepositoryProvider).getAvailability(arg);
  }

  Future<void> _drainRefresh() async {
    do {
      _refreshQueued = false;
      await _refreshQuietBody();
    } while (_refreshQueued && !_disposed);
  }

  Future<void> _refreshQuietBody() async {
    final previous = state.asData?.value;
    try {
      final data = await _fetch();
      if (_disposed) return;
      state = AsyncData(data);
    } catch (error, stack) {
      if (_disposed) return;
      if (previous != null) {
        state = AsyncError<PitchAvailability>(
          error,
          stack,
        ).copyWithPrevious(AsyncData(previous));
      } else {
        state = AsyncError(error, stack);
      }
    }
  }

  void _syncPolling() {
    _stopPolling();
    if (_disposed || !_foreground) return;
    final interval = ref.read(availabilityPollIntervalProvider);
    if (interval == null) return;
    _poll = Timer.periodic(interval, (_) {
      if (_disposed || !_foreground) return;
      unawaited(refreshQuiet());
    });
  }

  void _stopPolling() {
    _poll?.cancel();
    _poll = null;
  }
}
