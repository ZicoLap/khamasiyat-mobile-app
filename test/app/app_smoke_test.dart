import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/bootstrap/app.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/core/config/app_config.dart';
import 'package:khamasiyat_mobile_app/core/config/app_environment.dart';
import 'package:khamasiyat_mobile_app/core/config/providers.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/core/storage/secure_token_store.dart';
import 'package:khamasiyat_mobile_app/core/storage/token_store_provider.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_repository.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_remote.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start without tokens reaches Arabic login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final localeController = await LocaleController.create();
    final tokens = InMemoryTokenStore();
    final repository = AuthRepository(
      api: FakeAuthRemote(),
      tokenStore: tokens,
    );
    final controller = AuthController(
      repository: repository,
      restoreOnStart: false,
      initialState: const AuthUnauthenticated(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              environment: AppEnvironment.development,
              apiBaseUrl: 'http://10.0.2.2:3000',
              enableNetworkLogging: false,
              connectTimeout: Duration(seconds: 5),
              receiveTimeout: Duration(seconds: 5),
              sendTimeout: Duration(seconds: 5),
            ),
          ),
          localeControllerProvider.overrideWith((ref) => localeController),
          tokenStoreProvider.overrideWithValue(tokens),
          authRepositoryProvider.overrideWithValue(repository),
          authControllerProvider.overrideWith((ref) => controller),
        ],
        child: const KhamasiyatApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الدخول'), findsWidgets);
  });
}
