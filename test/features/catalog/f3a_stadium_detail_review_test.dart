import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_detail_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/stadium_detail_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

import '../../helpers/fake_catalog_remote.dart';
import '../../helpers/solid_color_image.dart';

/// F3A Stadium Detail hero/content overlap — regenerate with:
/// `flutter test --update-goldens test/features/catalog/f3a_stadium_detail_review_test.dart`
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

  Future<void> prepare(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
  }

  Widget frame({required Locale locale, required String name}) {
    final stadium = sampleStadiumDetail(
      name: name,
      photoUrls: const ['https://cdn.example/nile.jpg'],
      pitches: const [
        StadiumPitchSummary(
          id: 'p1',
          name: 'Pitch A',
          type: PitchType.fiveASide,
          surfaceType: SurfaceType.artificialTurf,
          isIndoor: false,
          hasRoof: false,
          lengthMeters: 40,
          widthMeters: 20,
        ),
        StadiumPitchSummary(
          id: 'p2',
          name: 'Pitch B',
          type: PitchType.fiveASide,
          surfaceType: SurfaceType.artificialTurf,
          isIndoor: false,
          hasRoof: true,
          lengthMeters: 40,
          widthMeters: 20,
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          CatalogRepository(
            FakeCatalogRemote(stadiumById: {stadium.id: stadium}),
          ),
        ),
      ],
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
        home: RepaintBoundary(
          key: const ValueKey('review-root'),
          child: StadiumDetailScreen(stadiumId: stadium.id),
        ),
      ),
    );
  }

  Future<void> golden(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('review-root')),
      matchesGoldenFile('../../../docs/f3a-visual-review/$name.png'),
    );
  }

  testWidgets('1 english stadium detail 390 overlap', (tester) async {
    await prepare(tester);
    await tester.pumpWidget(
      frame(locale: const Locale('en'), name: 'Al-Nile Stadium'),
    );
    await golden(tester, '01_en_stadium_detail_390');
  });

  testWidgets('2 arabic stadium detail 390 overlap', (tester) async {
    await prepare(tester);
    await tester.pumpWidget(
      frame(locale: const Locale('ar'), name: 'ملعب النيل'),
    );
    await golden(tester, '02_ar_stadium_detail_390');
  });
}
