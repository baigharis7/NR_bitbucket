import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/screen_top_bar.dart';

/// Guards against the regression where the selected-day header on screens
/// like Add Food rendered as 'Thu, Jan 15 2026' even when the app was set
/// to Spanish. The DateFormat call now passes the active locale.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
    await initializeDateFormatting('en', null);
  });

  Widget buildTestWidget({
    required DateTime selectedDate,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: Scaffold(
        body: ScreenTopBar(
          selectedDate: selectedDate,
          onBack: () {},
        ),
      ),
    );
  }

  group('ScreenTopBar selected-date label', () {
    testWidgets('renders weekday + month in Spanish when locale is es',
        (tester) async {
      // 2026-01-15 is a Thursday — 'Thu' in EN, 'jue' in ES.
      // January is 'Jan'/'ene' so we hit both abbreviated tokens.
      final date = DateTime(2026, 1, 15);

      await tester.pumpWidget(buildTestWidget(
        selectedDate: date,
        locale: const Locale('es'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('jue, ene 15 2026'), findsOneWidget);
      expect(find.text('Thu, Jan 15 2026'), findsNothing);
    });

    testWidgets('renders weekday + month in English when locale is en',
        (tester) async {
      final date = DateTime(2026, 1, 15);

      await tester.pumpWidget(buildTestWidget(
        selectedDate: date,
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Thu, Jan 15 2026'), findsOneWidget);
    });
  });
}
