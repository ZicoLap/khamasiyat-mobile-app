import 'package:khamasiyat_mobile_app/core/config/app_environment.dart';

/// Immutable application configuration resolved at bootstrap.
///
/// Values come from `--dart-define` / `--dart-define-from-file`.
/// Never hardcode production hostnames inside repositories or widgets.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableNetworkLogging,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
  });

  /// Active deploy environment.
  final AppEnvironment environment;

  /// Origin only (scheme + host + optional port). API path `/api/v1` is appended
  /// by the HTTP client.
  ///
  /// Examples:
  /// - Android emulator → NestJS on host: `http://10.0.2.2:3000`
  /// - iOS simulator → NestJS on host: `http://127.0.0.1:3000`
  /// - Physical device → machine LAN IP (do not commit a personal IP).
  final String apiBaseUrl;

  /// Verbose Dio logging. Must remain false in production builds.
  final bool enableNetworkLogging;

  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  /// Full API root including `/api/v1`.
  String get apiRoot {
    final base = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    return '$base/api/v1';
  }

  bool get isProduction => environment == AppEnvironment.production;

  /// Builds config from compile-time defines.
  ///
  /// Supported defines:
  /// - `ENV` — `development` | `staging` | `production` (default: development)
  /// - `API_BASE_URL` — backend origin (default depends on ENV)
  /// - `ENABLE_NETWORK_LOGGING` — `true` | `false` (default: true in development only)
  factory AppConfig.fromEnvironment() {
    const envRaw = String.fromEnvironment('ENV', defaultValue: 'development');
    final environment = AppEnvironment.fromString(envRaw);

    const apiBaseUrlDefine = String.fromEnvironment('API_BASE_URL');
    final apiBaseUrl = apiBaseUrlDefine.isNotEmpty
        ? apiBaseUrlDefine
        : _defaultApiBaseUrl(environment);

    const loggingDefine = String.fromEnvironment('ENABLE_NETWORK_LOGGING');
    final enableNetworkLogging = loggingDefine.isNotEmpty
        ? loggingDefine.toLowerCase() == 'true'
        : environment == AppEnvironment.development;

    // Production must never enable verbose network logging via defaults.
    final safeLogging =
        environment == AppEnvironment.production ? false : enableNetworkLogging;

    return AppConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      enableNetworkLogging: safeLogging,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );
  }

  static String _defaultApiBaseUrl(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.development:
        // Android emulator loopback to host machine. Override with API_BASE_URL
        // for iOS simulator (127.0.0.1) or physical devices (LAN IP).
        return 'http://10.0.2.2:3000';
      case AppEnvironment.staging:
        return 'https://staging-api.khamasiyat.example';
      case AppEnvironment.production:
        return 'https://api.khamasiyat.example';
    }
  }
}
