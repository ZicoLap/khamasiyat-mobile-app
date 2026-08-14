import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/catalog_widgets.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

import '../../helpers/fake_catalog_remote.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child, {Locale locale = const Locale('en')}) {
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
      home: Scaffold(body: child),
    );
  }

  testWidgets('filters button opens sheet; apply commits draft', (
    tester,
  ) async {
    CatalogFilters filters = CatalogFilters.empty;

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return CatalogFilterControls(
              filters: filters,
              onApplied: (next) => setState(() => filters = next),
              onClearAll: () => setState(() => filters = CatalogFilters.empty),
            );
          },
        ),
      ),
    );

    expect(find.text('Filters'), findsOneWidget);
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    expect(find.text('Show results'), findsOneWidget);
    await tester.tap(find.text('Khartoum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show results'));
    await tester.pumpAndSettle();

    expect(filters.state, SudanState.khartoum);
    expect(find.text('Khartoum'), findsOneWidget);
    expect(find.textContaining('Filters · 1'), findsOneWidget);
  });

  testWidgets('selected filter chips clear individually and via clear all', (
    tester,
  ) async {
    CatalogFilters filters = const CatalogFilters(
      state: SudanState.khartoum,
      pitchType: PitchType.fiveASide,
    );

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return CatalogFilterControls(
              filters: filters,
              onApplied: (next) => setState(() => filters = next),
              onClearAll: () => setState(() => filters = CatalogFilters.empty),
            );
          },
        ),
      ),
    );

    expect(find.text('Khartoum'), findsOneWidget);
    expect(find.text('5-a-side'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);

    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();
    expect(filters.hasAny, isFalse);
    expect(find.text('Filters'), findsOneWidget);
  });

  testWidgets('filter sheet reset clears draft before apply', (tester) async {
    CatalogFilters filters = const CatalogFilters(state: SudanState.khartoum);

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return CatalogFilterControls(
              filters: filters,
              onApplied: (next) => setState(() => filters = next),
            );
          },
        ),
      ),
    );

    await tester.tap(find.textContaining('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show results'));
    await tester.pumpAndSettle();

    expect(filters.hasAny, isFalse);
  });

  testWidgets('Arabic filter sheet and chips', (tester) async {
    await tester.pumpWidget(
      wrap(
        CatalogFilterControls(
          filters: const CatalogFilters(pitchType: PitchType.fiveASide),
          onApplied: (_) {},
          onClearAll: () {},
        ),
        locale: const Locale('ar'),
      ),
    );

    expect(find.text('خماسي'), findsOneWidget);
    expect(find.text('مسح الكل'), findsOneWidget);

    await tester.tap(find.textContaining('فلاتر'));
    await tester.pumpAndSettle();
    expect(find.text('الفلاتر'), findsOneWidget);
    expect(find.text('عرض النتائج'), findsOneWidget);
    expect(find.text('إعادة ضبط'), findsOneWidget);
  });

  testWidgets('discovery card missing and present photo states', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(DiscoveryStadiumCard(stadium: sampleStadium())),
    );
    await tester.pump();
    expect(find.text('Photo soon'), findsOneWidget);
    expect(find.text('Nile Arena'), findsOneWidget);

    await tester.pumpWidget(
      wrap(
        DiscoveryStadiumCard(
          stadium: sampleStadium(photoUrl: 'https://example.com/hero.jpg'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('compact search card layout', (tester) async {
    await tester.pumpWidget(wrap(CompactStadiumCard(stadium: sampleStadium())));
    await tester.pump();
    expect(find.text('Nile Arena'), findsOneWidget);
    expect(find.textContaining('Omdurman'), findsOneWidget);
    expect(find.textContaining('pitch'), findsOneWidget);
  });

  testWidgets('skeleton list renders without spinner', (tester) async {
    await tester.pumpWidget(
      wrap(
        const CustomScrollView(slivers: [CatalogSkeletonList(itemCount: 2)]),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(AspectRatio), findsNWidgets(2));
  });

  testWidgets('narrow width keeps discovery card readable', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrap(
        DiscoveryStadiumCard(
          stadium: sampleStadium(
            name: 'Very Long Stadium Name For Narrow Phones',
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Very Long Stadium'), findsOneWidget);
  });

  testWidgets('Arabic RTL compact card', (tester) async {
    await tester.pumpWidget(
      wrap(
        CompactStadiumCard(stadium: sampleStadium(name: 'ملعب النيل')),
        locale: const Locale('ar'),
      ),
    );
    await tester.pump();
    expect(find.text('ملعب النيل'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('ملعب النيل'))),
      TextDirection.rtl,
    );
  });
}
