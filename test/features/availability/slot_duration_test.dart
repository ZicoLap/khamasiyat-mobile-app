import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/slot_duration.dart';
import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations_en.dart';

void main() {
  test('duration is end minus start across hour boundaries', () {
    expect(SlotDuration.minutesBetween('20:00', '21:30'), 90);
    expect(SlotDuration.minutesBetween('08:00', '09:00'), 60);
    expect(SlotDuration.minutesBetween('10:00', '10:30'), 30);
    expect(SlotDuration.minutesBetween('23:00', '00:30'), 90);
  });

  test('duration labels use hours and minutes', () {
    final l10n = AppLocalizationsEn();
    expect(SlotDuration.label(90, l10n), '1h 30m');
    expect(SlotDuration.label(60, l10n), '1h');
    expect(SlotDuration.label(30, l10n), '30m');
  });
}
