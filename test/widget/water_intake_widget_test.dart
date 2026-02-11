import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/water_intake_wigdet.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/ani_nutri_progress_bar_widget.dart';

void main() {
  Widget buildTestWidget({
    required double totalLitersGoal,
    required int consumedGlasses,
    Function? onInfoClick,
    Function? onAddWater,
    Function? onRemoveWater,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: Scaffold(
        body: SingleChildScrollView(
          child: WaterIntakeWidget(
            totalLitersGoal: totalLitersGoal,
            consumedGlasses: consumedGlasses,
            onInfoClick: onInfoClick,
            onAddWater: onAddWater ?? () {},
            onRemoveWater: onRemoveWater ?? () {},
          ),
        ),
      ),
    );
  }

  group('TS-HY0001 & TS-HY0002: Hydration Widget Tests', () {
    // TS-HY0001 Step 1 / TS-HY0002 Step 1:
    // "From Dashboard, locate the Hydration section."
    testWidgets('renders hydration title', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        totalLitersGoal: 2.0,
        consumedGlasses: 0,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hydration'), findsOneWidget);
    });

    // TS-HY0001 Step 2: glass icons are present under Hydration
    testWidgets('renders correct total number of glasses based on goal',
        (tester) async {
      // 2.0L goal / 0.25L per glass = 8 glasses
      await tester.pumpWidget(buildTestWidget(
        totalLitersGoal: 2.0,
        consumedGlasses: 0,
      ));
      await tester.pumpAndSettle();

      final inkWells = find.byType(InkWell);
      // 8 glass InkWells + possibly 1 info button InkWell
      expect(inkWells.evaluate().length, greaterThanOrEqualTo(8));
    });

    // TS-HY0001 Step 3: "The glass fills to indicate added water"
    testWidgets('renders filled glasses for consumed count and empty for rest',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        totalLitersGoal: 2.0,
        consumedGlasses: 3,
      ));
      await tester.pumpAndSettle();

      // Check that filled glasses use filled_glass.png
      // and empty glasses use empty_glass.png
      int filledCount = 0;
      int emptyCount = 0;

      final containers = find.byType(Container);
      for (final element in containers.evaluate()) {
        final widget = element.widget as Container;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration && decoration.image != null) {
          final assetImage = decoration.image!.image;
          if (assetImage is AssetImage) {
            if (assetImage.assetName == 'assets/images/filled_glass.png') {
              filledCount++;
            } else if (assetImage.assetName ==
                'assets/images/empty_glass.png') {
              emptyCount++;
            }
          }
        }
      }

      expect(filledCount, 3);
      expect(emptyCount, 5); // 8 total - 3 filled = 5 empty
    });

    // TS-HY0001 Step 2: empty glasses show "+" icon for tapping
    testWidgets('empty glasses show add icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        totalLitersGoal: 2.0,
        consumedGlasses: 3,
      ));
      await tester.pumpAndSettle();

      // 5 empty glasses should each show an add icon
      expect(find.byIcon(Icons.add), findsNWidgets(5));
    });

    // TS-HY0001 Core:
    // "Tap on a glass icon under Hydration" (empty glass)
    // "The selected glass icon fills up, indicating a glass of water has been added.
    //  Hydration count increases by 1."
    testWidgets('tapping an empty glass calls onAddWater callback',
        (tester) async {
      bool addWaterCalled = false;

      await tester.pumpWidget(buildTestWidget(
        totalLitersGoal: 2.0,
        consumedGlasses: 3,
        onAddWater: () => addWaterCalled = true,
      ));
      await tester.pumpAndSettle();

      // Tap the first empty glass (index 3, the 4th glass which is empty)
      // Find all add icons (they are inside empty glasses)
      final addIcons = find.byIcon(Icons.add);
      expect(addIcons, findsNWidgets(5));

      await tester.tap(addIcons.first);
      await tester.pumpAndSettle();

      expect(addWaterCalled, isTrue);
    });

    // TS-HY0002 Core:
    // "Tap again on a filled glass icon."
    // "The selected glass icon un-fills, indicating the water entry was removed.
    //  Hydration count decreases by 1."
    testWidgets('tapping a filled glass calls onRemoveWater callback',
        (tester) async {
      bool removeWaterCalled = false;

      await tester.pumpWidget(buildTestWidget(
        totalLitersGoal: 2.0,
        consumedGlasses: 3,
        onRemoveWater: () => removeWaterCalled = true,
      ));
      await tester.pumpAndSettle();

      // Find a filled glass container and tap it.
      // Filled glasses don't have the add icon, so we find containers
      // with filled_glass.png and tap their parent InkWell.
      final containers = find.byType(Container);
      Finder? filledGlassInkWell;

      for (final element in containers.evaluate()) {
        final widget = element.widget as Container;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration && decoration.image != null) {
          final assetImage = decoration.image!.image;
          if (assetImage is AssetImage &&
              assetImage.assetName == 'assets/images/filled_glass.png') {
            // Find the ancestor InkWell of this container
            filledGlassInkWell = find.ancestor(
              of: find.byWidget(widget),
              matching: find.byType(InkWell),
            );
            break;
          }
        }
      }

      expect(filledGlassInkWell, isNotNull);
      await tester.tap(filledGlassInkWell!.first);
      await tester.pumpAndSettle();

      expect(removeWaterCalled, isTrue);
    });

    // TS-HY0001 Step 4: "Confirm the water total increases by one unit."
    // Verifies the consumed liters text is displayed correctly.
    testWidgets('displays consumed liters text', (tester) async {
      // 3 glasses * 0.25L = 0.75L
      await tester.pumpWidget(buildTestWidget(
        totalLitersGoal: 2.0,
        consumedGlasses: 3,
      ));
      await tester.pumpAndSettle();

      expect(find.text('0.75 L.'), findsOneWidget);
    });

    // TS-HY0001 Step 4: goal text is shown
    testWidgets('displays goal liters text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        totalLitersGoal: 2.0,
        consumedGlasses: 3,
      ));
      await tester.pumpAndSettle();

      expect(find.text('out of 2.00 liters.'), findsOneWidget);
    });

    // Progress bar reflects hydration progress
    testWidgets('progress bar receives correct percentage', (tester) async {
      // 3 glasses * 0.25 = 0.75L consumed, goal = 2.0L
      // progress = 0.75 / 2.0 = 0.375, percent = 37.5
      await tester.pumpWidget(buildTestWidget(
        totalLitersGoal: 2.0,
        consumedGlasses: 3,
      ));
      await tester.pumpAndSettle();

      final progressBar = tester.widget<AnimatedNutrientProgressBarWidget>(
        find.byType(AnimatedNutrientProgressBarWidget),
      );
      expect(progressBar.percent, closeTo(37.5, 0.01));
    });

    // Edge case: no water consumed yet
    testWidgets('zero consumed glasses shows all empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        totalLitersGoal: 2.0,
        consumedGlasses: 0,
      ));
      await tester.pumpAndSettle();

      // All 8 glasses should show add icon (all empty)
      expect(find.byIcon(Icons.add), findsNWidgets(8));
      expect(find.text('0.00 L.'), findsOneWidget);
    });

    // Edge case: all glasses consumed
    testWidgets('fully consumed shows all filled glasses', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        totalLitersGoal: 2.0,
        consumedGlasses: 8, // 8 glasses = 2.0L
      ));
      await tester.pumpAndSettle();

      // No add icons should be shown (all glasses filled)
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.text('2.00 L.'), findsOneWidget);
    });
  });
}
