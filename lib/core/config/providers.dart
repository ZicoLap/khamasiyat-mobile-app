import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/config/app_config.dart';

/// Root application configuration. Overridden in tests via [ProviderScope].
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
