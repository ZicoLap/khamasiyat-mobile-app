import 'dart:convert';

import 'package:khamasiyat_mobile_app/features/realtime/domain/realtime_models.dart';

/// Turns a UTF-8 byte stream into [SseEvent]s.
Stream<SseEvent> decodeSseStream(Stream<List<int>> bytes) async* {
  final buffer = StringBuffer();
  await for (final chunk in bytes) {
    buffer.write(utf8.decode(chunk, allowMalformed: true));
    final text = buffer
        .toString()
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final parts = text.split('\n\n');
    buffer
      ..clear()
      ..write(parts.removeLast());
    for (final block in parts) {
      final event = SseEvent.parse(block);
      if (event != null) yield event;
    }
  }
  final tail = SseEvent.parse(buffer.toString());
  if (tail != null) yield tail;
}
