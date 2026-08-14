import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/shared/validation/sudan_phone.dart';

void main() {
  group('SudanPhone', () {
    test('normalizes local leading-zero mobile to E.164', () {
      expect(SudanPhone.normalizeToE164('0912345678'), '+249912345678');
    });

    test('normalizes national significant number', () {
      expect(SudanPhone.normalizeToE164('912345678'), '+249912345678');
    });

    test('accepts already-E.164 values', () {
      expect(SudanPhone.normalizeToE164('+249912345678'), '+249912345678');
    });

    test('rejects invalid shapes', () {
      expect(SudanPhone.normalizeToE164('123'), isNull);
      expect(SudanPhone.isValidMobile('abcdefghij'), isFalse);
    });

    test('toNationalSignificant strips country code', () {
      expect(SudanPhone.toNationalSignificant('+249912345678'), '912345678');
    });
  });
}
