import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/features/realtime/data/sse_decoder.dart';
import 'package:khamasiyat_mobile_app/features/realtime/domain/realtime_models.dart';
import 'package:khamasiyat_mobile_app/features/realtime/presentation/pitch_realtime_controller.dart';

void main() {
  group('SseEvent.parse', () {
    test('parses named event and data', () {
      final event = SseEvent.parse(
        'event: availability.changed\ndata: {"pitchId":"p1"}',
      );
      expect(event?.event, 'availability.changed');
      expect(event?.data, '{"pitchId":"p1"}');
    });

    test('defaults event to message and ignores comments', () {
      final event = SseEvent.parse(': keep-alive\ndata: hello');
      expect(event?.event, 'message');
      expect(event?.data, 'hello');
    });

    test('joins multiple data lines', () {
      final event = SseEvent.parse('event: heartbeat\ndata: {\ndata: }');
      expect(event?.event, 'heartbeat');
      expect(event?.data, '{\n}');
    });
  });

  test('decodeSseStream yields events split across chunks', () async {
    final events =
        await decodeSseStream(
          Stream<List<int>>.fromIterable([
            utf8.encode('event: availability.changed\n'),
            utf8.encode('data: {"pitchId":"p1"}\n\n'),
            utf8.encode('event: heartbeat\ndata: {"occurredAt":"t"}\n\n'),
          ]),
        ).toList();
    expect(events, hasLength(2));
    expect(events.first.event, 'availability.changed');
    expect(events.last.event, 'heartbeat');
  });

  test('AvailabilityChangedHint ignores non-string occurrenceId', () {
    final hint = AvailabilityChangedHint.fromJson({
      'pitchId': 'p1',
      'occurrenceId': null,
      'reason': 'held',
    });
    expect(hint.pitchId, 'p1');
    expect(hint.occurrenceId, isNull);
    expect(hint.reason, 'held');
  });

  test('realtime backoff doubles then caps at 30s', () {
    expect(realtimeBackoffForFailures(1), const Duration(seconds: 1));
    expect(realtimeBackoffForFailures(2), const Duration(seconds: 2));
    expect(realtimeBackoffForFailures(3), const Duration(seconds: 4));
    expect(realtimeBackoffForFailures(4), const Duration(seconds: 8));
    expect(realtimeBackoffForFailures(5), const Duration(seconds: 16));
    expect(realtimeBackoffForFailures(6), const Duration(seconds: 30));
    expect(realtimeBackoffForFailures(20), const Duration(seconds: 30));
  });
}
