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

/// F2.2 filter-sheet goldens — regenerate with:
/// `flutter test --update-goldens test/features/catalog/f22_visual_review_test.dart`
///
/// Home/Search mock goldens from this suite were retired; current Home/Search
/// visual contracts live in F2.3.1.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> prepare(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 720);
    tester.view.devicePixelRatio = 1.0;
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
      matchesGoldenFile('../../../docs/f2.2-visual-review/$name.png'),
    );
  }

  testWidgets('english filter bottom sheet', (tester) async {
    await prepare(tester);
    await tester.pumpWidget(
      frame(
        locale: const Locale('en'),
        child: const CatalogFilterSheet(
          initial: CatalogFilters(state: SudanState.khartoum),
        ),
      ),
    );
    expect(find.text('Show results'), findsOneWidget);
    expect(find.text('Khartoum'), findsWidgets);
    await golden(tester, '03_en_filters');
  });

  testWidgets('arabic filter bottom sheet', (tester) async {
    await prepare(tester);
    await tester.pumpWidget(
      frame(
        locale: const Locale('ar'),
        child: const CatalogFilterSheet(
          initial: CatalogFilters(pitchType: PitchType.fiveASide),
        ),
      ),
    );
    expect(find.text('عرض النتائج'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('عرض النتائج'))),
      TextDirection.rtl,
    );
    await golden(tester, '06_ar_filters');
  });
}
