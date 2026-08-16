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
import 'package:khamasiyat_mobile_app/features/auth/data/auth_repository.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/my_bookings_controller.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:khamasiyat_mobile_app/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_auth_remote.dart';
import '../../helpers/fake_bookings_remote.dart';
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
    tokens = InMemoryTokenStore();
    remote = FakeAuthRemote(meUser: buildAuthUser());
    repository = AuthRepository(api: remote, tokenStore: tokens);
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    await tokens.saveTokens(accessToken: 'a', refreshToken: 'r');
    SharedPreferences.setMockInitialValues({'app.locale_code': 'en'});
    final localeController = await LocaleController.create();
    final authController = AuthController(
      repository: repository,
      restoreOnStart: false,
      initialState: AuthAuthenticated(buildAuthUser()),
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
          bookingsRepositoryProvider.overrideWithValue(
            BookingsRepository(FakeBookingsRemote()),
          ),
          myBookingsHoldTickIntervalProvider.overrideWithValue(null),
        ],
        child: const KhamasiyatApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
  }

  test('profileInitials uses first and last names', () {
    expect(profileInitials('Customer'), 'C');
    expect(profileInitials('Ada Lovelace'), 'AL');
    expect(profileInitials('  '), '?');
  });

  testWidgets('profile shows identity and always offers change password', (
    tester,
  ) async {
    await pumpProfile(tester);

    expect(find.text('Your profile'), findsOneWidget);
    expect(find.text('Customer'), findsWidgets);
    expect(find.text('customer@example.com'), findsWidgets);
    expect(find.text('+249912345678'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Email and phone cannot be changed here.'), findsOneWidget);
    expect(find.text('Edit name'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sign out'), 200);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('edit name submits PATCH payload and updates header', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Edit name'));
    await tester.pumpAndSettle();

    expect(find.text('Save name'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'New Name');
    await tester.tap(find.widgetWithText(FilledButton, 'Save name'));
    await tester.pumpAndSettle();

    expect(remote.updateMeCallCount, 1);
    expect(remote.lastUpdateMeRequest?.name, 'New Name');
    expect(find.text('New Name'), findsWidgets);
    expect(find.text('Name updated.'), findsOneWidget);
  });

  testWidgets('logout from profile returns to login', (tester) async {
    await pumpProfile(tester);

    await tester.scrollUntilVisible(find.text('Sign out'), 200);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    expect(remote.logoutCallCount, 1);
  });
}
