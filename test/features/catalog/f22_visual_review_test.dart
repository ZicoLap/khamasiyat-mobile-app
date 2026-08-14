import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/catalog_widgets.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

import '../../helpers/fake_catalog_remote.dart';
import '../../helpers/solid_color_image.dart';

/// F2.2 visual review goldens — regenerate with:
/// `flutter test --update-goldens test/features/catalog/f22_visual_review_test.dart`
///
/// Outputs live under `docs/f2.2-visual-review/`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const fixtures = <String, Color>{
      'https://cdn.example/nile.jpg': Color(0xFF1F6B4A),
      'https://cdn.example/green.jpg': Color(0xFF2E8B57),
      'https://cdn.example/bahri.jpg': Color(0xFF3A7D5C),
    };
    StadiumPhoto.debugImageProviderForUrl = (url) {
      return SolidColorImageProvider(
        fixtures[url] ?? const Color(0xFF245C45),
        dimension: 128,
      );
    };
  });
  tearDownAll(() {
    StadiumPhoto.debugImageProviderForUrl = null;
  });

  Future<void> prepare(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget frame({
    required Locale locale,
    required Widget child,
  }) {
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
        body: RepaintBoundary(
          key: const ValueKey('review-root'),
          child: child,
        ),
      ),
    );
  }

  final withPhotos = [
    sampleStadium(
      id: '1',
      name: 'Nile Arena',
      photoUrl: 'https://cdn.example/nile.jpg',
      activePitchCount: 3,
    ),
    sampleStadium(
      id: '2',
      name: 'Green Field Club',
      city: SudanCity.khartoumCity,
      photoUrl: 'https://cdn.example/green.jpg',
      activePitchCount: 2,
    ),
    sampleStadium(
      id: '3',
      name: 'Bahri Sports Hub',
      city: SudanCity.bahri,
      photoUrl: 'https://cdn.example/bahri.jpg',
      activePitchCount: 4,
    ),
  ];

  Future<void> golden(
    WidgetTester tester,
    String name,
  ) async {
    await tester.pump();
    await expectLater(
      find.byKey(const ValueKey('review-root')),
      matchesGoldenFile('../../../docs/f2.2-visual-review/$name.png'),
    );
  }

  testWidgets('1 english home with stadium images', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      frame(
        locale: const Locale('en'),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.brandDeep,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Khamasiyat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('Hi, Sara', style: TextStyle(color: Color(0xFFB7D9C8))),
                  SizedBox(height: 8),
                  Text(
                    'Find your next match',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ColoredBox(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Stadiums',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            ...withPhotos.map(
              (s) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: DiscoveryStadiumCard(stadium: s),
              ),
            ),
          ],
        ),
      ),
    );
    expect(find.text('Nile Arena'), findsOneWidget);
    await golden(tester, '01_en_home');
  });

  testWidgets('2 english search with results', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      frame(
        locale: const Locale('en'),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Search',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text('State, city, or pitch type'),
            const SizedBox(height: 8),
            const Text('3 stadiums'),
            const SizedBox(height: 12),
            ...withPhotos.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CompactStadiumCard(stadium: s),
              ),
            ),
          ],
        ),
      ),
    );
    expect(find.byType(CompactStadiumCard), findsNWidgets(3));
    await golden(tester, '02_en_search');
  });

  testWidgets('3 english filter bottom sheet', (tester) async {
    await prepare(tester, const Size(390, 720));
    await tester.pumpWidget(
      frame(
        locale: const Locale('en'),
        child: const CatalogFilterSheet(
          initial: CatalogFilters(state: SudanState.khartoum),
        ),
      ),
    );
    expect(find.text('Show results'), findsOneWidget);
    await golden(tester, '03_en_filters');
  });

  testWidgets('4 arabic home', (tester) async {
    await prepare(tester, const Size(390, 844));
    final arPhotos = [
      sampleStadium(
        id: '1',
        name: 'ملعب النيل',
        photoUrl: 'https://cdn.example/nile.jpg',
        activePitchCount: 3,
      ),
      sampleStadium(
        id: '2',
        name: 'نادي الملعب الأخضر',
        city: SudanCity.khartoumCity,
        photoUrl: 'https://cdn.example/green.jpg',
      ),
    ];
    await tester.pumpWidget(
      frame(
        locale: const Locale('ar'),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.brandDeep,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'خماسيات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'أهلًا، سارة',
                    style: TextStyle(color: Color(0xFFB7D9C8)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'احجز مباراتك الجاية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            ...arPhotos.map(
              (s) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: DiscoveryStadiumCard(stadium: s),
              ),
            ),
          ],
        ),
      ),
    );
    expect(find.text('ملعب النيل'), findsOneWidget);
    await golden(tester, '04_ar_home');
  });

  testWidgets('5 arabic search', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      frame(
        locale: const Locale('ar'),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'بحث',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('3 ملاعب'),
            const SizedBox(height: 12),
            CompactStadiumCard(
              stadium: sampleStadium(
                name: 'ملعب النيل',
                photoUrl: 'https://cdn.example/nile.jpg',
              ),
            ),
            const SizedBox(height: 8),
            CompactStadiumCard(
              stadium: sampleStadium(
                id: '2',
                name: 'نادي الملعب الأخضر',
                photoUrl: 'https://cdn.example/green.jpg',
              ),
            ),
          ],
        ),
      ),
    );
    expect(find.text('بحث'), findsOneWidget);
    await golden(tester, '05_ar_search');
  });

  testWidgets('6 arabic filter bottom sheet', (tester) async {
    await prepare(tester, const Size(390, 720));
    await tester.pumpWidget(
      frame(
        locale: const Locale('ar'),
        child: const CatalogFilterSheet(
          initial: CatalogFilters(pitchType: PitchType.fiveASide),
        ),
      ),
    );
    expect(find.text('عرض النتائج'), findsOneWidget);
    await golden(tester, '06_ar_filters');
  });

  testWidgets('7 home missing-photo fallback', (tester) async {
    await prepare(tester, const Size(390, 844));
    await tester.pumpWidget(
      frame(
        locale: const Locale('en'),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DiscoveryStadiumCard(stadium: sampleStadium(name: 'No Photo Pitch')),
            const SizedBox(height: 16),
            DiscoveryStadiumCard(
              stadium: sampleStadium(
                id: '2',
                name: 'Also Missing',
                city: SudanCity.bahri,
              ),
            ),
          ],
        ),
      ),
    );
    expect(find.text('Photo soon'), findsWidgets);
    await golden(tester, '07_en_missing_photo');
  });
}
