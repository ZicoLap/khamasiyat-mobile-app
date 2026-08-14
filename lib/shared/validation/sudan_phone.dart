/// Sudan mobile phone normalization and light client-side validation.
///
/// Backend validation remains authoritative. This helper only assists UI
/// input (E.164 display/normalization) and does not encode business rules
/// beyond well-known Sudan numbering shape.
abstract final class SudanPhone {
  /// Sudan country calling code.
  static const countryCode = '249';

  /// Digits-only national mobile numbers are typically 9 digits starting with 9.
  static final RegExp _nationalMobile = RegExp(r'^9\d{8}$');

  /// Attempts to normalize user input to E.164 (`+249…`).
  ///
  /// Accepts forms such as:
  /// - `0912345678`
  /// - `912345678`
  /// - `+249912345678`
  /// - `249912345678`
  ///
  /// Returns `null` when the input cannot be normalized confidently.
  static String? normalizeToE164(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    var digits = trimmed.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.startsWith('+')) {
      digits = digits.substring(1);
    }

    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }

    if (digits.startsWith('0') && digits.length == 10) {
      digits = digits.substring(1);
    }

    if (digits.startsWith(countryCode) && digits.length == countryCode.length + 9) {
      final national = digits.substring(countryCode.length);
      if (_nationalMobile.hasMatch(national)) {
        return '+$digits';
      }
      return null;
    }

    if (_nationalMobile.hasMatch(digits)) {
      return '+$countryCode$digits';
    }

    return null;
  }

  /// Returns true when [input] normalizes to a plausible Sudan mobile E.164.
  static bool isValidMobile(String input) {
    return normalizeToE164(input) != null;
  }

  /// Strips to national significant number (9 digits) when possible.
  static String? toNationalSignificant(String input) {
    final e164 = normalizeToE164(input);
    if (e164 == null) {
      return null;
    }
    return e164.substring(1 + countryCode.length);
  }
}
