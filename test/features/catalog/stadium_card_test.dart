import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_theme.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/catalog_widgets.dart';

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

  testWidgets('stadium card without image shows placeholder', (tester) async {
    await tester.pumpWidget(wrap(StadiumCard(stadium: sampleStadium())));
    await tester.pump();
    expect(find.text('Nile Arena'), findsOneWidget);
    expect(find.text('Photo soon'), findsOneWidget);
    expect(find.textContaining('Omdurman'), findsOneWidget);
  });

  testWidgets('stadium card with image URL builds network image', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        StadiumCard(
          stadium: sampleStadium(photoUrl: 'https://example.com/x.jpg'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('empty and error states render', (tester) async {
    await tester.pumpWidget(wrap(const CatalogEmptyView()));
    expect(find.text('No stadiums found'), findsOneWidget);

    await tester.pumpWidget(
      wrap(CatalogErrorView(message: 'Network unavailable', onRetry: () {})),
    );
    expect(find.text('Couldn’t load stadiums'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Arabic RTL stadium card', (tester) async {
    await tester.pumpWidget(
      wrap(
        Directionality(
          textDirection: TextDirection.rtl,
          child: StadiumCard(stadium: sampleStadium(name: 'ملعب النيل')),
        ),
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
