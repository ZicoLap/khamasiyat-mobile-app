import 'package:uuid/uuid.dart';

/// One idempotency key per logical "Book this slot" attempt on a slot.
class BookingAttemptKeys {
  BookingAttemptKeys({String Function()? createKey})
    : _createKey = createKey ?? _newUuid;

  static String _newUuid() => const Uuid().v4();

  final String Function() _createKey;
  String? _slotOccurrenceId;
  String? _key;

  String keyFor(String slotOccurrenceId) {
    if (_slotOccurrenceId != slotOccurrenceId || _key == null) {
      _slotOccurrenceId = slotOccurrenceId;
      _key = _createKey();
    }
    return _key!;
  }

  void reset() {
    _slotOccurrenceId = null;
    _key = null;
  }
}
