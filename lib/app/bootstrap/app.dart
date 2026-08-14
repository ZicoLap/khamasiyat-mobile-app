import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/router/app_router.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';

/// Root Material application wired with Riverpod, go_router, theme, and l10n.
class KhamasiyatApp extends ConsumerWidget {
  const KhamasiyatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
