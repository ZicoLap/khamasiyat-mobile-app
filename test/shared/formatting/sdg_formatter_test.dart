import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/shared/formatting/sdg_formatter.dart';

void main() {
  group('SdgFormatter', () {
    test('formats amount with SDG suffix', () {
      final formatted = SdgFormatter.format(1250, locale: 'en');
      expect(formatted, contains('1'));
      expect(formatted, contains('250'));
      expect(formatted, endsWith('SDG'));
    });

    test('respects decimal digits', () {
      final formatted = SdgFormatter.format(10.5, locale: 'en', decimalDigits: 1);
      expect(formatted, contains('10.5'));
      expect(formatted, endsWith('SDG'));
    });
  });
}
