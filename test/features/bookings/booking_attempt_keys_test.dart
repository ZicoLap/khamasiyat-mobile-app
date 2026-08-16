import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_attempt_keys.dart';

void main() {
  test('reuses the same key for retries of one slot', () {
    var n = 0;
    final keys = BookingAttemptKeys(createKey: () => 'k${++n}');
    expect(keys.keyFor('s1'), 'k1');
    expect(keys.keyFor('s1'), 'k1');
    expect(n, 1);
  });

  test('new slot selection starts a new attempt key', () {
    var n = 0;
    final keys = BookingAttemptKeys(createKey: () => 'k${++n}');
    expect(keys.keyFor('s1'), 'k1');
    expect(keys.keyFor('s2'), 'k2');
    expect(keys.keyFor('s2'), 'k2');
    expect(n, 2);
  });

  test('reset allows a new key for the same slot', () {
    var n = 0;
    final keys = BookingAttemptKeys(createKey: () => 'k${++n}');
    expect(keys.keyFor('s1'), 'k1');
    keys.reset();
    expect(keys.keyFor('s1'), 'k2');
  });
}
