import 'package:clock/clock.dart';
import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations.dart';

/// Parts of day for Home hero greetings.
enum DayPart { morning, afternoon, evening }

/// Resolves time-of-day from a testable [Clock] (F0).
DayPart dayPartFor(Clock clock) {
  final hour = clock.now().hour;
  if (hour < 12) {
    return DayPart.morning;
  }
  if (hour < 17) {
    return DayPart.afternoon;
  }
  return DayPart.evening;
}

/// Localized Home greeting. [firstName] is never translated.
String homeGreeting({
  required AppLocalizations l10n,
  required Clock clock,
  required String firstName,
}) {
  final part = dayPartFor(clock);
  final named = firstName.trim().isNotEmpty;
  switch (part) {
    case DayPart.morning:
      return named
          ? l10n.homeGreetingMorningNamed(firstName.trim())
          : l10n.homeGreetingMorningGeneric;
    case DayPart.afternoon:
      return named
          ? l10n.homeGreetingAfternoonNamed(firstName.trim())
          : l10n.homeGreetingAfternoonGeneric;
    case DayPart.evening:
      return named
          ? l10n.homeGreetingEveningNamed(firstName.trim())
          : l10n.homeGreetingEveningGeneric;
  }
}
