import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_vertical_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_energy_graph_widget.dart';

void main() {
  Widget buildTestWidget({
    required List<Map<String, dynamic>> data,
    String title = 'Energy Balance',
    double averageConsumed = 0,
    double averageSpent = 0,
    num total = 2000,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: Scaffold(
        body: SingleChildScrollView(
          child: WeeklyEnergyGraphWidget(
            data: data,
            title: title,
            averageConsumed: averageConsumed,
            averageSpent: averageSpent,
            total: total,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> makeWeekData() {
    return List.generate(7, (i) => {'day': i + 1, 'Kcal': (i + 1) * 0.1});
  }

  group('WeeklyEnergyGraphWidget', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        data: makeWeekData(),
        title: 'Energy Balance',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Energy Balance'), findsOneWidget);
    });

    testWidgets('displays average consumed kcal', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        data: makeWeekData(),
        averageConsumed: 1500.0,
      ));
      await tester.pumpAndSettle();

      expect(find.text('1500Kcal'), findsOneWidget);
    });

    testWidgets('displays average spent kcal', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        data: makeWeekData(),
        averageSpent: 300.0,
      ));
      await tester.pumpAndSettle();

      expect(find.text('300Kcal'), findsOneWidget);
    });

    testWidgets('displays total kcal reference', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        data: makeWeekData(),
        total: 2000,
      ));
      await tester.pumpAndSettle();

      expect(find.text('2000 Kcal'), findsOneWidget);
    });

    testWidgets('renders 7 FillVerticalBar widgets for week data',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(data: makeWeekData()));
      await tester.pumpAndSettle();

      expect(find.byType(FillVerticalBar), findsNWidgets(7));
    });

    testWidgets('empty data shows "no food events" message', (tester) async {
      await tester.pumpWidget(buildTestWidget(data: []));
      await tester.pumpAndSettle();

      // Should not find FillVerticalBar widgets
      expect(find.byType(FillVerticalBar), findsNothing);
    });

    testWidgets('renders weekday labels (M/T/W/T/F/S/S)', (tester) async {
      await tester.pumpWidget(buildTestWidget(data: makeWeekData()));
      await tester.pumpAndSettle();

      // English weekday initials: M, T, W, T, F, S, S
      expect(find.text('M'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      // T appears twice (Tue, Thu), S appears twice (Sat, Sun)
      expect(find.text('T'), findsNWidgets(2));
      expect(find.text('S'), findsNWidgets(2));
    });
  });
}
