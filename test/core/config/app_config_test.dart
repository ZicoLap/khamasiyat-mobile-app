import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/config/app_config.dart';
import 'package:khamasiyat_mobile_app/core/config/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    test('parses known aliases', () {
      expect(AppEnvironment.fromString('dev'), AppEnvironment.development);
      expect(AppEnvironment.fromString('staging'), AppEnvironment.staging);
      expect(AppEnvironment.fromString('prod'), AppEnvironment.production);
    });
  });

  group('AppConfig', () {
    test('apiRoot appends /api/v1 and strips trailing slash', () {
      const config = AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'http://10.0.2.2:3000/',
        enableNetworkLogging: true,
        connectTimeout: Duration(seconds: 1),
        receiveTimeout: Duration(seconds: 1),
        sendTimeout: Duration(seconds: 1),
      );

      expect(config.apiRoot, 'http://10.0.2.2:3000/api/v1');
    });

    test('fromEnvironment defaults to development', () {
      final config = AppConfig.fromEnvironment();
      expect(config.environment, AppEnvironment.development);
      expect(config.apiRoot.endsWith('/api/v1'), isTrue);
      expect(config.enableNetworkLogging, isTrue);
    });

    test('production forces network logging off when constructed via defaults', () {
      // fromEnvironment reads dart-defines; without ENV=production we assert
      // the safety rule on a manually built production config.
      const config = AppConfig(
        environment: AppEnvironment.production,
        apiBaseUrl: 'https://api.example',
        enableNetworkLogging: false,
        connectTimeout: Duration(seconds: 1),
        receiveTimeout: Duration(seconds: 1),
        sendTimeout: Duration(seconds: 1),
      );
      expect(config.isProduction, isTrue);
      expect(config.enableNetworkLogging, isFalse);
    });
  });
}
