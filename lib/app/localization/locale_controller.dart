import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePrefsKey = 'app.locale_code';

/// Supported Customer app locales. Arabic is the product default.
abstract final class AppLocales {
  static const arabic = Locale('ar');
  static const english = Locale('en');

  static const supported = <Locale>[arabic, english];

  static const Locale defaultLocale = arabic;
}

/// Persisted locale preference + Riverpod notifier for runtime switching.
class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._prefs, {Locale? initial})
      : super(initial ?? AppLocales.defaultLocale);

  final SharedPreferences _prefs;

  static Future<LocaleController> create() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_localePrefsKey);
    final initial = _parseLocale(stored) ?? AppLocales.defaultLocale;
    return LocaleController(prefs, initial: initial);
  }

  static Locale? _parseLocale(String? code) {
    if (code == null || code.isEmpty) {
      return null;
    }
    for (final locale in AppLocales.supported) {
      if (locale.languageCode == code) {
        return locale;
      }
    }
    return null;
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppLocales.supported.contains(locale)) {
      return;
    }
    state = locale;
    await _prefs.setString(_localePrefsKey, locale.languageCode);
  }

  Future<void> toggleArabicEnglish() async {
    final next = state.languageCode == 'ar'
        ? AppLocales.english
        : AppLocales.arabic;
    await setLocale(next);
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  throw UnimplementedError(
    'localeControllerProvider must be overridden in bootstrap',
  );
});
