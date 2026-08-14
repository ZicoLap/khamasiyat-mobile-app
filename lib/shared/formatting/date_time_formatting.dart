/// Extension points for date/time display formatting.
///
/// Prefer stadium wall-clock helpers in `core/clock/stadium_time.dart` for
/// booking slots. Use this module for UI-oriented date labels once product
/// copy is finalized.
abstract final class DateTimeFormatting {
  /// Formats a calendar date `yyyy-MM-dd` for display without timezone shifts.
  static String formatIsoDate(String isoDate) {
    // Keep opaque for F0; product screens will localize patterns later.
    return isoDate;
  }
}
