/// Time-handling strategy for Khamasiyat Customer app.
///
/// ## Backend contract (authoritative)
/// The platform uses stadium / booking time zones — commonly `Africa/Khartoum`
/// (UTC+2, no DST historically for this product context).
///
/// ## Rules
/// 1. **Instant timestamps** (ISO-8601 with `Z` or an explicit offset) represent
///    absolute moments. Parse them as UTC/offset-aware [DateTime] values.
/// 2. **Wall-clock booking fields** such as `HH:mm`, local calendar dates, or
///    "slot start/end" without an offset are **stadium-local**. Treat them as
///    opaque civil time — do **not** interpret them as UTC and convert via
///    `DateTime.parse(...).toLocal()`.
/// 3. Device timezone must not silently rewrite stadium wall-clock values when
///    displaying availability or booking windows.
/// 4. Hold expiry / payment deadlines that are absolute instants should use
///    rule (1). Countdown UI should be based on server-provided instants when
///    available.
///
/// ## F0 helpers
/// This file documents the strategy and provides light parsing utilities.
/// Full timezone database support (e.g. `timezone` package) can be added when
/// product UI needs named-zone conversions beyond Africa/Khartoum.
abstract final class StadiumTime {
  /// IANA id commonly used by Sudan stadium bookings.
  static const defaultTimeZoneId = 'Africa/Khartoum';

  /// Parses an absolute ISO-8601 instant. Returns UTC [DateTime].
  static DateTime parseInstant(String iso8601) {
    final parsed = DateTime.parse(iso8601);
    return parsed.toUtc();
  }

  /// Parses a wall-clock `HH:mm` or `HH:mm:ss` without timezone conversion.
  ///
  /// Returns minutes from midnight for ordering/comparison within a local day.
  static int parseWallClockToMinutes(String wallClock) {
    final parts = wallClock.split(':');
    if (parts.length < 2) {
      throw FormatException('Invalid wall-clock time: $wallClock');
    }
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw FormatException('Invalid wall-clock time: $wallClock');
    }
    return hour * 60 + minute;
  }

  /// Formats minutes-from-midnight as `HH:mm`.
  static String formatMinutesAsWallClock(int minutes) {
    if (minutes < 0 || minutes >= 24 * 60) {
      throw ArgumentError.value(minutes, 'minutes', 'out of day range');
    }
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
