import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/features/home/presentation/home_greeting.dart';
import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations_ar.dart';
import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();
  final ar = AppLocalizationsAr();

  Clock atHour(int hour) =>
      Clock.fixed(DateTime(2026, 8, 14, hour, 0));

  test('dayPartFor maps morning afternoon evening', () {
    expect(dayPartFor(atHour(8)), DayPart.morning);
    expect(dayPartFor(atHour(11)), DayPart.morning);
    expect(dayPartFor(atHour(12)), DayPart.afternoon);
    expect(dayPartFor(atHour(16)), DayPart.afternoon);
    expect(dayPartFor(atHour(17)), DayPart.evening);
    expect(dayPartFor(atHour(22)), DayPart.evening);
  });

  test('English named morning greeting', () {
    expect(
      homeGreeting(l10n: en, clock: atHour(9), firstName: 'Zakaria'),
      'Good morning, Zakaria 👋',
    );
  });

  test('English afternoon and evening greetings', () {
    expect(
      homeGreeting(l10n: en, clock: atHour(14), firstName: 'Sara'),
      'Good afternoon, Sara 👋',
    );
    expect(
      homeGreeting(l10n: en, clock: atHour(19), firstName: 'Sara'),
      'Good evening, Sara 👋',
    );
  });

  test('Arabic greeting keeps given name untranslated', () {
    expect(
      homeGreeting(l10n: ar, clock: atHour(9), firstName: 'أحمد'),
      'صباح الخير، أحمد 👋',
    );
    expect(
      homeGreeting(l10n: ar, clock: atHour(18), firstName: 'Zakaria'),
      'مساء الخير، Zakaria 👋',
    );
  });

  test('generic greeting without name', () {
    expect(
      homeGreeting(l10n: en, clock: atHour(10), firstName: ''),
      'Good morning 👋',
    );
    expect(
      homeGreeting(l10n: ar, clock: atHour(20), firstName: '  '),
      'مساء الخير 👋',
    );
  });
}
