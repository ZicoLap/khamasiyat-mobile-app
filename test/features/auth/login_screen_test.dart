import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:khamasiyat_mobile_app/features/auth/data/auth_dtos.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_repository.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_tokens.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_auth_remote.dart';
import '../../helpers/fake_catalog_remote.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:3000',
  enableNetworkLogging: false,
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
  sendTimeout: Duration(seconds: 5),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryTokenStore tokens;
  late FakeAuthRemote remote;
  late AuthRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tokens = InMemoryTokenStore();
    remote = FakeAuthRemote();
    repository = AuthRepository(api: remote, tokenStore: tokens);
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    Locale locale = const Locale('ar'),
    AuthController? controller,
  }) async {
    SharedPreferences.setMockInitialValues({
      'app.locale_code': locale.languageCode,
    });
    final localeController = await LocaleController.create();
    final authController = controller ??
        AuthController(
          repository: repository,
          restoreOnStart: false,
          initialState: const AuthUnauthenticated(),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          localeControllerProvider.overrideWith((ref) => localeController),
          tokenStoreProvider.overrideWithValue(tokens),
          authRepositoryProvider.overrideWithValue(repository),
          authControllerProvider.overrideWith((ref) => authController),
          catalogRepositoryProvider.overrideWithValue(
            CatalogRepository(
              FakeCatalogRemote(
                pages: {
                  1: StadiumListPage(
                    items: [sampleStadium()],
                    total: 1,
                    page: 1,
                    limit: 20,
                  ),
                },
              ),
            ),
          ),
        ],
        child: const KhamasiyatApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('login shows Arabic title and validates empty submit', (tester) async {
    await pumpApp(tester);

    expect(find.text('تسجيل الدخول'), findsWidgets);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('البريد مطلوب'), findsOneWidget);
  });

  testWidgets('login loading disables submit then routes home', (tester) async {
    final gate = Completer<void>();
    remote = _GatedLoginRemote(gate);
    repository = AuthRepository(api: remote, tokenStore: tokens);

    await pumpApp(tester, locale: const Locale('en'));

    await tester.enterText(find.byType(TextFormField).at(0), 'c@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Password1');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.textContaining('Your next game starts here'), findsOneWidget);
  });

  testWidgets('authenticated user is redirected away from login', (tester) async {
    final controller = AuthController(
      repository: repository,
      restoreOnStart: false,
      initialState: AuthAuthenticated(buildAuthUser()),
    );

    await pumpApp(tester, locale: const Locale('en'), controller: controller);
    expect(find.textContaining('Your next game starts here'), findsOneWidget);
    expect(find.text('Create an account'), findsNothing);
  });

  testWidgets('English login screen renders', (tester) async {
    await pumpApp(tester, locale: const Locale('en'));
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Create an account'), findsOneWidget);
  });
}

class _GatedLoginRemote extends FakeAuthRemote {
  _GatedLoginRemote(this.gate);

  final Completer<void> gate;

  @override
  Future<AuthSessionResult> login(LoginRequest request) async {
    await gate.future;
    return AuthSessionResult(
      tokens: const AuthTokens(accessToken: 'a', refreshToken: 'r'),
      user: buildAuthUser(),
    );
  }
}
