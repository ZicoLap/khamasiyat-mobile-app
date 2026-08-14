import 'package:flutter/widgets.dart';
import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations.dart';

export 'package:khamasiyat_mobile_app/l10n/generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
