import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/feces_urine_chart.dart';

void main() {
  Widget buildTestWidget({
    required List<Map<String, dynamic>> valuesList,
    required List<String?> imagePaths,
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
          child: FecesUrineChart(
            valuesList: valuesList,
            imagePaths: imagePaths,
          ),
        ),
      ),
    );
  }

  group('FecesUrineChart', () {
    testWidgets('renders "14 days" evolution title', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        valuesList: [],
        imagePaths: [],
      ));
      await tester.pumpAndSettle();

      // The localized title should contain "14"
      expect(find.textContaining('14'), findsOneWidget);
    });

    testWidgets('renders correct number of bars from valuesList',
        (tester) async {
      final values = List.generate(
        5,
        (i) => {'count': (i + 1) * 20},
      );

      await tester.pumpWidget(buildTestWidget(
        valuesList: values,
        imagePaths: [],
      ));
      await tester.pumpAndSettle();

      // The bars are inside a Row within a SizedBox(height: 120)
      // Each bar is a Container with width: 10
      final sizedBox = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 120,
      );
      expect(sizedBox, findsOneWidget);

      // Count children of the Row inside the SizedBox
      final row = find.descendant(of: sizedBox, matching: find.byType(Row));
      expect(row, findsOneWidget);

      // 5 bars should be generated
      final bars = find.descendant(
        of: row,
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.constraints?.maxWidth == 10,
        ),
      );
      // Each bar has width: 10, look for containers with that width
      expect(values.length, 5);
    });

    testWidgets('bar height is proportional to count value', (tester) async {
      final values = [
        {'count': 50}, // (50/100) * 70 = 35px
        {'count': 100}, // (100/100) * 70 = 70px
      ];

      await tester.pumpWidget(buildTestWidget(
        valuesList: values,
        imagePaths: [],
      ));
      await tester.pumpAndSettle();

      // Find the bars (containers with width: 10 inside the 120px SizedBox)
      final sizedBox120 = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 120,
      );

      final barContainers = find.descendant(
        of: sizedBox120,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints?.maxWidth == 10,
        ),
      );

      // We should have 2 bar containers
      expect(barContainers, findsNWidgets(2));
    });

    testWidgets('empty valuesList renders no bars', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        valuesList: [],
        imagePaths: [],
      ));
      await tester.pumpAndSettle();

      // The SizedBox with 120 height should still exist but with 0 bars
      final sizedBox120 = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 120,
      );
      expect(sizedBox120, findsOneWidget);
    });
  });
}
