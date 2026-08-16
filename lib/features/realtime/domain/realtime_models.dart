/// One SSE frame. [event] defaults to `message` when omitted.
class SseEvent {
  const SseEvent({required this.event, required this.data});

  final String event;
  final String data;

  /// Parses a single SSE dispatch block (no trailing blank line required).
  static SseEvent? parse(String block) {
    final trimmed = block.trim();
    if (trimmed.isEmpty) return null;

    String? event;
    final dataLines = <String>[];
    for (final rawLine in trimmed.split('\n')) {
      final line = rawLine.trimRight();
      if (line.isEmpty || line.startsWith(':')) continue;
      if (line.startsWith('event:')) {
        event = line.substring(6).trim();
        continue;
      }
      if (line.startsWith('data:')) {
        var value = line.substring(5);
        if (value.startsWith(' ')) value = value.substring(1);
        dataLines.add(value);
      }
    }
    if (event == null && dataLines.isEmpty) return null;
    return SseEvent(event: event ?? 'message', data: dataLines.join('\n'));
  }
}

class RealtimeStreamTicket {
  const RealtimeStreamTicket({
    required this.ticket,
    required this.expiresInSeconds,
  });

  final String ticket;
  final int expiresInSeconds;

  factory RealtimeStreamTicket.fromJson(Map<String, dynamic> json) {
    return RealtimeStreamTicket(
      ticket: json['ticket'] as String,
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 45,
    );
  }
}

/// Hint only — never used as slot inventory.
class AvailabilityChangedHint {
  const AvailabilityChangedHint({
    required this.pitchId,
    this.occurrenceId,
    this.reason,
    this.occurredAt,
  });

  final String pitchId;
  final String? occurrenceId;
  final String? reason;
  final String? occurredAt;

  factory AvailabilityChangedHint.fromJson(Map<String, dynamic> json) {
    final occurrence = json['occurrenceId'];
    return AvailabilityChangedHint(
      pitchId: json['pitchId'] as String,
      occurrenceId: occurrence is String ? occurrence : null,
      reason: json['reason'] as String?,
      occurredAt: json['occurredAt'] as String?,
    );
  }
}

class PitchRealtimeState {
  const PitchRealtimeState({this.generation = 0, this.connected = false});

  /// Increments on a debounced availability hint. Triggers GET refetch.
  final int generation;
  final bool connected;

  PitchRealtimeState copyWith({int? generation, bool? connected}) {
    return PitchRealtimeState(
      generation: generation ?? this.generation,
      connected: connected ?? this.connected,
    );
  }
}
