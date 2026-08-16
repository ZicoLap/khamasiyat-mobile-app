import 'package:khamasiyat_mobile_app/core/clock/stadium_time.dart';
import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations.dart';

/// Presentation-only duration from wall-clock start/end. Not a booking rule.
abstract final class SlotDuration {
  static int minutesBetween(String startTime, String endTime) {
    final start = StadiumTime.parseWallClockToMinutes(startTime);
    final end = StadiumTime.parseWallClockToMinutes(endTime);
    var minutes = end - start;
    if (minutes <= 0) {
      minutes += 24 * 60;
    }
    return minutes;
  }

  static String label(int minutes, AppLocalizations l10n) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours > 0 && remainder > 0) {
      return l10n.pitchDetailDurationHoursMinutes(hours, remainder);
    }
    if (hours > 0) {
      return l10n.pitchDetailDurationHours(hours);
    }
    return l10n.pitchDetailDurationMinutes(remainder);
  }
}
