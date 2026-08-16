import 'package:uuid/uuid.dart';

/// One idempotency key per logical payment submit attempt on a booking.
class PaymentAttemptKeys {
  PaymentAttemptKeys({String Function()? createKey})
    : _createKey = createKey ?? _newUuid;

  static String _newUuid() => const Uuid().v4();

  final String Function() _createKey;
  String? _bookingId;
  String? _method;
  String? _key;

  String keyFor({required String bookingId, required String method}) {
    if (_bookingId != bookingId || _method != method || _key == null) {
      _bookingId = bookingId;
      _method = method;
      _key = _createKey();
    }
    return _key!;
  }

  void reset() {
    _bookingId = null;
    _method = null;
    _key = null;
  }
}
