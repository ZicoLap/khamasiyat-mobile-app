import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/config/providers.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/realtime/data/realtime_ticket_api.dart';
import 'package:khamasiyat_mobile_app/features/realtime/data/sse_connector.dart';
import 'package:khamasiyat_mobile_app/features/realtime/domain/realtime_models.dart';

/// Production default on. Widget tests that [pumpAndSettle] must disable this.
final availabilityRealtimeEnabledProvider = Provider<bool>((ref) => true);

final availabilityRealtimeDebounceProvider = Provider<Duration>((ref) {
  return const Duration(milliseconds: 500);
});

final realtimeTicketRemoteProvider = Provider<RealtimeTicketRemote>((ref) {
  return RealtimeTicketApi(ref.watch(apiClientProvider));
});

final sseDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  return Dio(
    BaseOptions(
      baseUrl: config.apiRoot,
      connectTimeout: config.connectTimeout,
      receiveTimeout: Duration.zero,
      sendTimeout: config.sendTimeout,
      headers: const {'Accept': 'text/event-stream'},
      responseType: ResponseType.stream,
    ),
  );
});

final sseConnectorProvider = Provider<SseConnector>((ref) {
  return DioSseConnector(ref.watch(sseDioProvider));
});

final pitchRealtimeProvider = NotifierProvider.autoDispose
    .family<PitchRealtimeNotifier, PitchRealtimeState, String>(
      PitchRealtimeNotifier.new,
    );

Duration realtimeBackoffForFailures(int failures) {
  final n = failures < 1 ? 1 : failures;
  final seconds = math.min(30, 1 << math.min(n - 1, 5));
  return Duration(seconds: seconds);
}

class PitchRealtimeNotifier
    extends AutoDisposeFamilyNotifier<PitchRealtimeState, String> {
  var _disposed = false;
  var _foreground = true;
  var _loopRunning = false;
  var _failures = 0;
  var _skipBackoff = false;
  CancelToken? _cancel;
  Timer? _reconnect;
  Completer<void>? _sleep;

  bool get isLoopRunning => _loopRunning;

  @override
  PitchRealtimeState build(String pitchId) {
    _disposed = false;
    _foreground = true;
    ref.onDispose(_cleanup);
    if (ref.read(availabilityRealtimeEnabledProvider)) {
      unawaited(Future<void>.microtask(_ensureLoop));
    }
    return const PitchRealtimeState();
  }

  void setForeground(bool foreground) {
    if (_disposed) return;
    final wasForeground = _foreground;
    _foreground = foreground;
    if (!foreground) {
      _pause();
      return;
    }
    if (wasForeground && _loopRunning) return;
    _skipBackoff = true;
    _cancelSleep();
    unawaited(_ensureLoop());
  }

  void alignForeground(bool foreground) {
    if (_disposed) return;
    if (_foreground == foreground) return;
    setForeground(foreground);
  }

  void _cleanup() {
    _disposed = true;
    _foreground = false;
    _pause();
  }

  void _pause() {
    _cancelSleep();
    final cancel = _cancel;
    _cancel = null;
    if (cancel != null && !cancel.isCancelled) {
      cancel.cancel('pitch realtime paused');
    }
  }

  void _cancelSleep() {
    _reconnect?.cancel();
    _reconnect = null;
    final sleep = _sleep;
    _sleep = null;
    if (sleep != null && !sleep.isCompleted) {
      sleep.complete();
    }
  }

  Future<void> _ensureLoop() async {
    if (_disposed || !_foreground || _loopRunning) return;
    if (!ref.read(availabilityRealtimeEnabledProvider)) return;
    _loopRunning = true;
    try {
      while (!_disposed && _foreground) {
        var failed = false;
        try {
          await _connectOnce();
        } on DioException catch (error) {
          if (_disposed || !_foreground) break;
          if (error.type == DioExceptionType.cancel) {
            continue;
          }
          failed = true;
          _failures += 1;
        } catch (_) {
          if (_disposed || !_foreground) break;
          failed = true;
          _failures += 1;
        }
        if (_disposed || !_foreground) break;
        state = state.copyWith(connected: false);
        if (!_skipBackoff) {
          await _wait(
            failed
                ? realtimeBackoffForFailures(_failures)
                : const Duration(milliseconds: 400),
          );
        }
        _skipBackoff = false;
      }
    } finally {
      _loopRunning = false;
      if (!_disposed) {
        state = state.copyWith(connected: false);
        if (_foreground && ref.read(availabilityRealtimeEnabledProvider)) {
          unawaited(Future<void>.microtask(_ensureLoop));
        }
      }
    }
  }

  Future<void> _connectOnce() async {
    final ticket = await ref
        .read(realtimeTicketRemoteProvider)
        .issueCustomerTicket(pitchId: arg);
    if (_disposed || !_foreground) return;
    _failures = 0;
    _cancel = CancelToken();
    await for (final event in ref
        .read(sseConnectorProvider)
        .connect(
          path: '/realtime/stream',
          queryParameters: {'ticket': ticket.ticket},
          cancelToken: _cancel!,
        )) {
      if (_disposed || !_foreground) break;
      _failures = 0;
      _handleEvent(event);
    }
  }

  Future<void> _wait(Duration duration) async {
    if (duration <= Duration.zero || _disposed || !_foreground) return;
    final sleep = Completer<void>();
    _sleep = sleep;
    _reconnect?.cancel();
    _reconnect = Timer(duration, () {
      if (!sleep.isCompleted) sleep.complete();
    });
    await sleep.future;
    if (identical(_sleep, sleep)) {
      _sleep = null;
    }
  }

  void _handleEvent(SseEvent event) {
    if (event.event == 'heartbeat') return;
    if (event.event != 'availability.changed') return;
    final hint = _parseHint(event.data);
    if (hint == null) return;
    if (hint.pitchId != arg) return;
    state = state.copyWith(generation: state.generation + 1, connected: true);
  }

  AvailabilityChangedHint? _parseHint(String data) {
    if (data.isEmpty) return null;
    try {
      final decoded = jsonDecode(data);
      if (decoded is! Map) return null;
      return AvailabilityChangedHint.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }
}
