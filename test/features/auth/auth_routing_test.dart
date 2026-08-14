import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/bootstrap/app.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/core/config/app_config.dart';
import 'package:khamasiyat_mobile_app/core/config/app_environment.dart';
import 'package:khamasiyat_mobile_app/core/config/providers.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/core/storage/secure_token_store.dart';
import 'package:khamasiyat_mobile_app/core/storage/token_store_provider.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_repository.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
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
  late AuthRepository authRepository;
  late FakeCatalogRemote catalogRemote;

  setUp(() {
    tokens = InMemoryTokenStore();
    authRepository = AuthRepository(api: FakeAuthRemote(), tokenStore: tokens);
    catalogRemote = FakeCatalogRemote(
      pages: {
        1: StadiumListPage(
          items: [sampleStadium()],
          total: 1,
          page: 1,
          limit: 20,
        ),
      },
    );
  });

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    required AuthState initial,
    Locale locale = const Locale('en'),
    bool settle = true,
  }) async {
    SharedPreferences.setMockInitialValues({
      'app.locale_code': locale.languageCode,
    });
    final localeController = await LocaleController.create();
    final authController = AuthController(
      repository: authRepository,
      restoreOnStart: false,
      initialState: initial,
    );

    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        localeControllerProvider.overrideWith((ref) => localeController),
        tokenStoreProvider.overrideWithValue(tokens),
        authRepositoryProvider.overrideWithValue(authRepository),
        authControllerProvider.overrideWith((ref) => authController),
        catalogRepositoryProvider.overrideWithValue(
          CatalogRepository(catalogRemote),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const KhamasiyatApp(),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
    return container;
  }

  testWidgets('initializing shows splash and not login', (tester) async {
    await pumpApp(tester, initial: const AuthInitializing(), settle: false);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets('unauthenticated lands on login', (tester) async {
    await pumpApp(tester, initial: const AuthUnauthenticated());
    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('authenticated lands on home shell', (tester) async {
    await pumpApp(tester, initial: AuthAuthenticated(buildAuthUser()));
    expect(find.textContaining('Your next game starts here'), findsOneWidget);
    expect(find.text('Explore stadiums'), findsOneWidget);
    expect(find.text('Khamasiyat'), findsOneWidget);
    expect(find.text('Find a stadium'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsWidgets);
  });

  testWidgets('Arabic home renders RTL copy', (tester) async {
    await pumpApp(
      tester,
      initial: AuthAuthenticated(buildAuthUser(name: 'أحمد')),
      locale: const Locale('ar'),
    );
    expect(find.textContaining('مباراتك الجاية تبدأ من هنا'), findsOneWidget);
    expect(find.text('استكشف الملاعب'), findsOneWidget);
    expect(find.text('خماسيات'), findsOneWidget);
    expect(find.text('ابحث عن ملعب'), findsNothing);
    expect(find.text('الرئيسية'), findsOneWidget);
  });

  testWidgets('mustChangePassword forces change-password route', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initial: AuthAuthenticated(buildAuthUser(mustChangePassword: true)),
    );
    expect(find.text('Change password'), findsWidgets);
  });

  testWidgets('See all opens Search tab', (tester) async {
    await pumpApp(tester, initial: AuthAuthenticated(buildAuthUser()));
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.text('State, city, or pitch type'), findsOneWidget);
  });

  testWidgets('bottom navigation switches to search and bookings', (
    tester,
  ) async {
    await pumpApp(tester, initial: AuthAuthenticated(buildAuthUser()));

    await tester.tap(find.text('Search').last);
    await tester.pumpAndSettle();
    expect(find.text('Search'), findsWidgets);
    expect(find.text('State, city, or pitch type'), findsOneWidget);

    await tester.tap(find.text('Bookings'));
    await tester.pumpAndSettle();
    expect(find.text('Your bookings'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Your profile'), findsOneWidget);
  });

  testWidgets('register navigation works from login', (tester) async {
    final container = await pumpApp(
      tester,
      initial: const AuthUnauthenticated(),
    );
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsWidgets);
    expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
    expect(AppRoutes.search, '/search');
  });
}
