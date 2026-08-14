import 'package:intl/intl.dart';

/// Formats Sudanese Pound (SDG) amounts for display.
///
/// The backend remains authoritative for prices. This helper only formats
/// numeric amounts already returned by the API.
abstract final class SdgFormatter {
  static const currencyCode = 'SDG';

  /// Formats [amount] using the given [locale] (defaults to Arabic Sudan).
  ///
  /// Example (en): `1,250 SDG`
  /// Example (ar): `١٬٢٥٠ ج.س` depending on locale data availability;
  /// falls back to a stable `amount SDG` pattern when needed.
  static String format(
    num amount, {
    String locale = 'ar',
    int decimalDigits = 0,
  }) {
    final number = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return '${number.format(amount)} $currencyCode';
  }
}
