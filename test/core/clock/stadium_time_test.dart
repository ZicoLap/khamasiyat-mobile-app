import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/clock/stadium_time.dart';

void main() {
  group('StadiumTime', () {
    test('parses instant as UTC', () {
      final instant = StadiumTime.parseInstant('2026-08-14T10:00:00.000Z');
      expect(instant.isUtc, isTrue);
      expect(instant.hour, 10);
    });

    test('parses wall-clock without timezone conversion', () {
      expect(StadiumTime.parseWallClockToMinutes('09:30'), 9 * 60 + 30);
      expect(StadiumTime.formatMinutesAsWallClock(570), '09:30');
    });

    test('rejects invalid wall-clock', () {
      expect(
        () => StadiumTime.parseWallClockToMinutes('25:00'),
        throwsFormatException,
      );
    });
  });
}
