import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:khamasiyat_mobile_app/features/realtime/data/realtime_ticket_api.dart';
import 'package:khamasiyat_mobile_app/features/realtime/data/sse_connector.dart';
import 'package:khamasiyat_mobile_app/features/realtime/domain/realtime_models.dart';

class FakeRealtimeTicketRemote implements RealtimeTicketRemote {
  FakeRealtimeTicketRemote({this.failWith, this.ticketPrefix = 'rt_'});

  Object? failWith;
  String ticketPrefix;
  final requestedPitchIds = <String>[];

  @override
  Future<RealtimeStreamTicket> issueCustomerTicket({
    required String pitchId,
  }) async {
    requestedPitchIds.add(pitchId);
    if (failWith != null) {
      throw failWith!;
    }
    return RealtimeStreamTicket(
      ticket: '$ticketPrefix$pitchId',
      expiresInSeconds: 45,
    );
  }
}

class FakeSseConnector implements SseConnector {
  FakeSseConnector({this.failWith});

  Object? failWith;
  var connectCount = 0;
  final tickets = <String>[];
  final paths = <String>[];
  final _controllers = <StreamController<SseEvent>>[];

  int get openConnections =>
      _controllers.where((controller) => !controller.isClosed).length;

  bool get hasListener => _controllers.any(
    (controller) => !controller.isClosed && controller.hasListener,
  );

  @override
  Stream<SseEvent> connect({
    required String path,
    required Map<String, dynamic> queryParameters,
    required CancelToken cancelToken,
  }) {
    connectCount += 1;
    paths.add(path);
    tickets.add('${queryParameters['ticket']}');
    if (failWith != null) {
      return Stream<SseEvent>.error(failWith!);
    }
    final controller = StreamController<SseEvent>(sync: true);
    _controllers.add(controller);
    if (cancelToken.isCancelled) {
      scheduleMicrotask(() {
        if (!controller.isClosed) {
          controller.close();
        }
      });
    } else {
      cancelToken.whenCancel.then((_) {
        if (!controller.isClosed) {
          controller.close();
        }
      });
    }
    return controller.stream;
  }

  void emit(SseEvent event) {
    for (final controller in _controllers) {
      if (!controller.isClosed) {
        controller.add(event);
      }
    }
  }
}

SseEvent availabilityChangedEvent({
  required String pitchId,
  String? occurrenceId,
  String reason = 'created',
}) {
  return SseEvent(
    event: 'availability.changed',
    data: jsonEncode({
      'pitchId': pitchId,
      'reason': reason,
      'occurredAt': '2026-08-14T07:00:00.000Z',
      if (occurrenceId != null) 'occurrenceId': occurrenceId,
    }),
  );
}

SseEvent heartbeatEvent() {
  return const SseEvent(
    event: 'heartbeat',
    data: '{"occurredAt":"2026-08-14T07:00:00.000Z"}',
  );
}
