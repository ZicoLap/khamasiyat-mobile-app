import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/core/clock/app_clock.dart';
import 'package:khamasiyat_mobile_app/features/home/presentation/home_screen.dart';

import '../../helpers/solid_color_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap({
    required Widget child,
    Locale locale = const Locale('en'),
    Clock? clock,
  }) {
    return ProviderScope(
      overrides: [if (clock != null) appClockProvider.overrideWithValue(clock)],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('English hero copy and hierarchy without Search CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        clock: Clock.fixed(DateTime(2026, 8, 14, 9)),
        child: const HomeHero(
          brand: 'Khamasiyat',
          greeting: 'Good morning, Zakaria 👋',
          headline: 'Your next game starts here.',
          support: 'Discover and book football pitches across Sudan.',
          localeCode: 'en',
          onToggleLocale: _noop,
          languageTooltip: 'Language',
        ),
      ),
    );

    expect(find.text('Khamasiyat'), findsOneWidget);
    expect(find.text('Good morning, Zakaria 👋'), findsOneWidget);
    expect(find.text('Your next game starts here.'), findsOneWidget);
    expect(
      find.text('Discover and book football pitches across Sudan.'),
      findsOneWidget,
    );
    expect(find.text('Find a stadium'), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('Arabic RTL hero copy', (tester) async {
    await tester.pumpWidget(
      wrap(
        locale: const Locale('ar'),
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: HomeHero(
            brand: 'خماسيات',
            greeting: 'صباح الخير، أحمد 👋',
            headline: 'مباراتك الجاية تبدأ من هنا',
            support: 'اكتشف واحجز ملاعب كرة القدم في جميع أنحاء السودان',
            localeCode: 'ar',
            onToggleLocale: _noop,
            languageTooltip: 'اللغة',
          ),
        ),
      ),
    );

    expect(find.text('خماسيات'), findsOneWidget);
    expect(find.text('مباراتك الجاية تبدأ من هنا'), findsOneWidget);
    expect(find.text('ابحث عن ملعب'), findsNothing);
    expect(
      Directionality.of(tester.element(find.text('خماسيات'))),
      TextDirection.rtl,
    );
  });

  testWidgets('narrow 320px hero does not overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrap(
        child: const HomeHero(
          brand: 'Khamasiyat',
          greeting: 'Good afternoon, VeryLongFirstName 👋',
          headline: 'Your next game starts here.',
          support: 'Discover and book football pitches across Sudan.',
          localeCode: 'en',
          onToggleLocale: _noop,
          languageTooltip: 'Language',
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Your next game'), findsOneWidget);
  });

  testWidgets('hero without artwork stays compact; artwork optional', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        child: const HomeHero(
          brand: 'Khamasiyat',
          greeting: 'Good morning, Zakaria 👋',
          headline: 'Your next game starts here.',
          support: 'Discover and book football pitches across Sudan.',
          localeCode: 'en',
          onToggleLocale: _noop,
          languageTooltip: 'Language',
        ),
      ),
    );
    expect(find.byType(Image), findsNothing);

    await tester.pumpWidget(
      wrap(
        child: const HomeHero(
          brand: 'Khamasiyat',
          greeting: 'Good morning, Zakaria 👋',
          headline: 'Your next game starts here.',
          support: 'Discover and book football pitches across Sudan.',
          localeCode: 'en',
          decorativeArtwork: SolidColorImageProvider(
            Color(0xFF2E8B57),
            dimension: 64,
          ),
          onToggleLocale: _noop,
          languageTooltip: 'Language',
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Your next game starts here.'), findsOneWidget);
  });
}

void _noop() {}
