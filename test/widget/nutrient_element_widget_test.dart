import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/ani_nutri_progress_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/nutrient_element_widget.dart';

/// Anchor for the bug "Macros Appear Fully Completed in Green for New Accounts".
/// Until the goal>0 guard was added, NutrientElementWidget computed
/// `(current / goal).clamp(0.0, 1.0) * 100` which for a fresh account
/// (goal=0) produced NaN. NaN.clamp(...) returns NaN, the progress bar
/// then received `percent: NaN` and rendered with bogus width.
void main() {
  Widget buildTestWidget({
    required double current,
    required double goal,
    String label = 'Protein',
    String unit = 'g',
    Color progressColor = Colors.green,
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
          child: NutrientElementWidget(
            label: label,
            current: current,
            goal: goal,
            unit: unit,
            progressColor: progressColor,
          ),
        ),
      ),
    );
  }

  AnimatedNutrientProgressBarWidget findBar(WidgetTester tester) =>
      tester.widget<AnimatedNutrientProgressBarWidget>(
        find.byType(AnimatedNutrientProgressBarWidget),
      );

  group('NutrientElementWidget — goal=0 (fresh account, no kcal target)', () {
    testWidgets('renders without throwing when goal is 0 and current is 0',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 0, goal: 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('progress bar percent is 0 when goal is 0, not NaN',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 0, goal: 0));
      await tester.pumpAndSettle();
      expect(findBar(tester).percent, 0.0);
      expect(findBar(tester).percent.isNaN, isFalse);
    });

    testWidgets(
        'progress bar stays at 0 even if current > 0 but goal is 0',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 25, goal: 0));
      await tester.pumpAndSettle();
      expect(findBar(tester).percent, 0.0);
    });
  });

  group('NutrientElementWidget — display rounding policy (1 decimal)', () {
    testWidgets('shows consumed value with 1 decimal, not ceil/truncate',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 8.76, goal: 150));
      await tester.pumpAndSettle();
      // Pre-policy this widget rendered ceil() ("9") while the meal time
      // summary truncated ("8") — the same 8.76 g shown two different ways.
      expect(find.textContaining('8.8', findRichText: true), findsOneWidget);
    });

    testWidgets('goal stays integer ("/ 150"), only consumed gets decimals',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 8.76, goal: 150));
      await tester.pumpAndSettle();
      expect(find.textContaining('150', findRichText: true), findsOneWidget);
    });
  });

  group('NutrientElementWidget — normal path', () {
    testWidgets('progress bar matches current/goal ratio', (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 25, goal: 100));
      await tester.pumpAndSettle();
      expect(findBar(tester).percent, 25.0);
    });

    testWidgets('progress is clamped to 100 when exceeding goal',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 150, goal: 100));
      await tester.pumpAndSettle();
      expect(findBar(tester).percent, 100.0);
    });
  });
}
