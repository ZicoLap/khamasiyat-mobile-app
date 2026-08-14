import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/catalog_widgets.dart';
import 'package:khamasiyat_mobile_app/features/home/presentation/home_hero_artwork.dart';
import 'package:khamasiyat_mobile_app/features/home/presentation/home_screen.dart';

import '../../helpers/fake_catalog_remote.dart';
import '../../helpers/solid_color_image.dart';

/// F2.3.1 visual review — regenerate with:
/// `flutter test --update-goldens test/features/home/f231_home_hero_polish_review_test.dart`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    StadiumPhoto.debugImageProviderForUrl = (_) {
      return const SolidColorImageProvider(Color(0xFF1F6B4A), dimension: 128);
    };
  });
  tearDownAll(() {
    StadiumPhoto.debugImageProviderForUrl = null;
  });

  Future<void> prepare(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget frame({required Locale locale, required Widget child}) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        backgroundColor: AppColors.canvas,
        body: RepaintBoundary(key: const ValueKey('review-root'), child: child),
      ),
    );
  }

  Future<void> golden(WidgetTester tester, String name) async {
    await tester.pump();
    await expectLater(
      find.byKey(const ValueKey('review-root')),
      matchesGoldenFile('../../../docs/f2.3.1-visual-review/$name.png'),
    );
  }

  Widget homePreview({
    required String brand,
    required String greeting,
    required String headline,
    required String support,
    required String section,
    required String seeAll,
    required String localeCode,
    required List<StadiumListItem> stadiums,
    ImageProvider? artwork,
  }) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        HomeHero(
          brand: brand,
          greeting: greeting,
          headline: headline,
          support: support,
          localeCode: localeCode,
          decorativeArtwork: artwork,
          onToggleLocale: () {},
          languageTooltip: 'Language',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  section,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                seeAll,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...stadiums.map(
          (s) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DiscoveryStadiumCard(stadium: s),
          ),
        ),
      ],
    );
  }

  final withPhoto = [
    sampleStadium(
      name: 'Nile Arena',
      photoUrl: 'https://cdn.example/pitch.jpg',
      activePitchCount: 3,
    ),
  ];

  const art = AssetImage(HomeHeroArtwork.assetPath);

  testWidgets('1 variant A en 390 no artwork', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      frame(
        locale: const Locale('en'),
        child: homePreview(
          brand: 'Khamasiyat',
          greeting: 'Good morning, Zakaria 👋',
          headline: 'Your next game starts here.',
          support: 'Discover and book football pitches across Sudan.',
          section: 'Explore stadiums',
          seeAll: 'See all',
          localeCode: 'en',
          stadiums: withPhoto,
        ),
      ),
    );
    expect(find.text('Find a stadium'), findsNothing);
    await golden(tester, '01_variant_a_en_390');
  });

  testWidgets('2 variant B en 390 with artwork', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      frame(
        locale: const Locale('en'),
        child: homePreview(
          brand: 'Khamasiyat',
          greeting: 'Good morning, Zakaria 👋',
          headline: 'Your next game starts here.',
          support: 'Discover and book football pitches across Sudan.',
          section: 'Explore stadiums',
          seeAll: 'See all',
          localeCode: 'en',
          stadiums: withPhoto,
          artwork: art,
        ),
      ),
    );
    await tester.pump();
    await golden(tester, '02_variant_b_en_390');
  });

  testWidgets('3 variant B ar 390 with artwork', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      frame(
        locale: const Locale('ar'),
        child: homePreview(
          brand: 'خماسيات',
          greeting: 'صباح الخير، أحمد 👋',
          headline: 'مباراتك الجاية تبدأ من هنا',
          support: 'اكتشف واحجز ملاعب كرة القدم في جميع أنحاء السودان',
          section: 'استكشف الملاعب',
          seeAll: 'عرض الكل',
          localeCode: 'ar',
          stadiums: [
            sampleStadium(
              name: 'ملعب النيل',
              photoUrl: 'https://cdn.example/pitch.jpg',
            ),
          ],
          artwork: art,
        ),
      ),
    );
    await golden(tester, '03_variant_b_ar_390');
  });

  testWidgets('4 en 320 no artwork', (tester) async {
    await prepare(tester, const Size(320, 720));
    await tester.pumpWidget(
      frame(
        locale: const Locale('en'),
        child: homePreview(
          brand: 'Khamasiyat',
          greeting: 'Good afternoon, Sara 👋',
          headline: 'Your next game starts here.',
          support: 'Discover and book football pitches across Sudan.',
          section: 'Explore stadiums',
          seeAll: 'See all',
          localeCode: 'en',
          stadiums: withPhoto,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await golden(tester, '04_en_320');
  });

  testWidgets('5 ar 320 with artwork', (tester) async {
    await prepare(tester, const Size(320, 720));
    await tester.pumpWidget(
      frame(
        locale: const Locale('ar'),
        child: homePreview(
          brand: 'خماسيات',
          greeting: 'مساء الخير، سارة 👋',
          headline: 'مباراتك الجاية تبدأ من هنا',
          support: 'اكتشف واحجز ملاعب كرة القدم في جميع أنحاء السودان',
          section: 'استكشف الملاعب',
          seeAll: 'عرض الكل',
          localeCode: 'ar',
          stadiums: withPhoto,
          artwork: art,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await golden(tester, '05_ar_320');
  });

  testWidgets('6 missing photo without artwork', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      frame(
        locale: const Locale('en'),
        child: homePreview(
          brand: 'Khamasiyat',
          greeting: 'Good evening, Zakaria 👋',
          headline: 'Your next game starts here.',
          support: 'Discover and book football pitches across Sudan.',
          section: 'Explore stadiums',
          seeAll: 'See all',
          localeCode: 'en',
          stadiums: [sampleStadium(name: 'No Photo Pitch')],
        ),
      ),
    );
    expect(find.text('Photo soon'), findsOneWidget);
    await golden(tester, '06_missing_photo_no_art');
  });
}
