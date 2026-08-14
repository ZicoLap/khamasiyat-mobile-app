import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/register/register_verify_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OTP screen shows resend cooldown and English copy', (tester) async {
    SharedPreferences.setMockInitialValues({'app.locale_code': 'en'});
    final localeController = await LocaleController.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeControllerProvider.overrideWith((ref) => localeController),
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
          home: const RegisterVerifyScreen(email: 'c@example.com'),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('c@example.com'), findsOneWidget);
    expect(find.textContaining('Resend available in'), findsOneWidget);
    expect(find.text('Verification code'), findsOneWidget);
  });

  testWidgets('OTP screen renders RTL Arabic', (tester) async {
    SharedPreferences.setMockInitialValues({'app.locale_code': 'ar'});
    final localeController = await LocaleController.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeControllerProvider.overrideWith((ref) => localeController),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('ar'),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              return const Directionality(
                textDirection: TextDirection.rtl,
                child: RegisterVerifyScreen(email: 'c@example.com'),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('تأكيد البريد'), findsWidgets);
    expect(
      Directionality.of(tester.element(find.byType(Scaffold).first)),
      TextDirection.rtl,
    );
  });
}
