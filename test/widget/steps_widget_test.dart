import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/steps_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/ani_nutri_progress_bar_widget.dart';

void main() {
  Widget buildTestWidget({
    required int stepsTaken,
    required int stepsGoal,
    VoidCallback? onTap,
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
          child: StepsWidget(
            stepsTaken: stepsTaken,
            stepsGoal: stepsGoal,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  group('StepsWidget', () {
    testWidgets('renders steps title', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 5000,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Steps'), findsOneWidget);
    });

    testWidgets('renders steps icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 5000,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      final images = find.byType(Image);
      bool foundStepsIcon = false;
      for (final element in images.evaluate()) {
        final widget = element.widget as Image;
        if (widget.image is AssetImage) {
          final assetImage = widget.image as AssetImage;
          if (assetImage.assetName == 'assets/icon/steps_icon.png') {
            foundStepsIcon = true;
          }
        }
      }
      expect(foundStepsIcon, isTrue);
    });

    testWidgets('renders health sync icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 5000,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.monitor_heart), findsOneWidget);
    });

    testWidgets('formats step count under 1000 as plain number', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 500,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('formats step count in thousands correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 5000,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('formats non-round thousands with decimals', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 5500,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      expect(find.text('5.50'), findsOneWidget);
    });

    testWidgets('displays zero steps', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 0,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('progress bar receives correct percentage', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 5000,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      final progressBar = tester.widget<AnimatedNutrientProgressBarWidget>(
        find.byType(AnimatedNutrientProgressBarWidget),
      );
      // 5000/10000 = 0.5 → 50%
      expect(progressBar.percent, closeTo(50.0, 0.01));
    });

    testWidgets('progress bar clamps at 100% when over goal', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 15000,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      final progressBar = tester.widget<AnimatedNutrientProgressBarWidget>(
        find.byType(AnimatedNutrientProgressBarWidget),
      );
      expect(progressBar.percent, closeTo(100.0, 0.01));
    });

    testWidgets('progress bar is 0% when zero steps', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 0,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      final progressBar = tester.widget<AnimatedNutrientProgressBarWidget>(
        find.byType(AnimatedNutrientProgressBarWidget),
      );
      expect(progressBar.percent, closeTo(0.0, 0.01));
    });

    testWidgets('onTap callback is invoked when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 5000,
        stepsGoal: 10000,
        onTap: () => tapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });

    testWidgets('has background image decoration', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 5000,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      final containers = find.byType(Container);
      bool foundBkg = false;
      for (final element in containers.evaluate()) {
        final widget = element.widget as Container;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration && decoration.image != null) {
          final assetImage = decoration.image!.image;
          if (assetImage is AssetImage &&
              assetImage.assetName == 'assets/images/steps_bkg.jpg') {
            foundBkg = true;
          }
        }
      }
      expect(foundBkg, isTrue);
    });

    testWidgets('has correct background color', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stepsTaken: 5000,
        stepsGoal: 10000,
      ));
      await tester.pumpAndSettle();

      final containers = find.byType(Container);
      bool foundColor = false;
      for (final element in containers.evaluate()) {
        final widget = element.widget as Container;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration && decoration.color == const Color(0xFF6F0507)) {
          foundColor = true;
        }
      }
      expect(foundColor, isTrue);
    });
  });
}
