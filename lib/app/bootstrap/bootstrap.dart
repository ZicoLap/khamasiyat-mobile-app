import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/app/bootstrap/app.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/core/config/app_config.dart';
import 'package:khamasiyat_mobile_app/core/config/providers.dart';

/// Application entry wiring: binding, locale, ProviderScope, runApp.
Future<void> bootstrap({AppConfig? config}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final resolvedConfig = config ?? AppConfig.fromEnvironment();
  final localeController = await LocaleController.create();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(resolvedConfig),
        localeControllerProvider.overrideWith(
          (ref) => localeController,
        ),
      ],
      child: const KhamasiyatApp(),
    ),
  );
}
