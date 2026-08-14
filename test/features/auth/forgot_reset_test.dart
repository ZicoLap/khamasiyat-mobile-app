import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/core/storage/secure_token_store.dart';
import 'package:khamasiyat_mobile_app/features/auth/data/auth_repository.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/forgot_password/forgot_password_screen.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/forgot_password/reset_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_auth_remote.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('forgot password validates email', (tester) async {
    SharedPreferences.setMockInitialValues({'app.locale_code': 'en'});
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
          localeControllerProvider.overrideWith((ref) => localeController),
          authRepositoryProvider.overrideWithValue(repository),
          authControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ForgotPasswordScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('reset password validates OTP and mismatch', (tester) async {
    SharedPreferences.setMockInitialValues({'app.locale_code': 'en'});
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
          localeControllerProvider.overrideWith((ref) => localeController),
          authRepositoryProvider.overrideWithValue(repository),
          authControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ResetPasswordScreen(email: 'c@example.com'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'Password1');
    await tester.enterText(find.byType(TextFormField).at(2), 'Password2');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Enter the numeric verification code'), findsOneWidget);
  });
}
