import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/sleeping_hours_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/ani_nutri_progress_bar_widget.dart';

void main() {
  Widget buildTestWidget({
    required double hoursSlept,
    required double hoursGoal,
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
          child: SleepingHoursWidget(
            hoursSlept: hoursSlept,
            hoursGoal: hoursGoal,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  group('SleepingHoursWidget', () {
    testWidgets('renders sleeping hours title', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 7.5,
        hoursGoal: 8,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sleeping hours'), findsOneWidget);
    });

    testWidgets('renders sleep icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 7.5,
        hoursGoal: 8,
      ));
      await tester.pumpAndSettle();

      final images = find.byType(Image);
      bool foundSleepIcon = false;
      for (final element in images.evaluate()) {
        final widget = element.widget as Image;
        if (widget.image is AssetImage) {
          final assetImage = widget.image as AssetImage;
          if (assetImage.assetName == 'assets/icon/sleep_icon.png') {
            foundSleepIcon = true;
          }
        }
      }
      expect(foundSleepIcon, isTrue);
    });

    testWidgets('renders health sync icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 7.5,
        hoursGoal: 8,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.monitor_heart), findsOneWidget);
    });

    testWidgets('displays formatted hours correctly for whole hours', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 7.0,
        hoursGoal: 8,
      ));
      await tester.pumpAndSettle();

      expect(find.text('7:00 h.'), findsOneWidget);
    });

    testWidgets('displays formatted hours correctly for fractional hours', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 7.5,
        hoursGoal: 8,
      ));
      await tester.pumpAndSettle();

      expect(find.text('7:30 h.'), findsOneWidget);
    });

    testWidgets('displays zero hours correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 0,
        hoursGoal: 8,
      ));
      await tester.pumpAndSettle();

      expect(find.text('0:00 h.'), findsOneWidget);
    });

    testWidgets('displays goal text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 7.5,
        hoursGoal: 8,
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('8'), findsWidgets);
    });

    testWidgets('progress bar receives correct percentage', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 6.0,
        hoursGoal: 8.0,
      ));
      await tester.pumpAndSettle();

      final progressBar = tester.widget<AnimatedNutrientProgressBarWidget>(
        find.byType(AnimatedNutrientProgressBarWidget),
      );
      // 6/8 = 0.75 → 75%
      expect(progressBar.percent, closeTo(75.0, 0.01));
    });

    testWidgets('progress bar clamps at 100% when over goal', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 10.0,
        hoursGoal: 8.0,
      ));
      await tester.pumpAndSettle();

      final progressBar = tester.widget<AnimatedNutrientProgressBarWidget>(
        find.byType(AnimatedNutrientProgressBarWidget),
      );
      expect(progressBar.percent, closeTo(100.0, 0.01));
    });

    testWidgets('progress bar is 0% when zero hours slept', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 0,
        hoursGoal: 8.0,
      ));
      await tester.pumpAndSettle();

      final progressBar = tester.widget<AnimatedNutrientProgressBarWidget>(
        find.byType(AnimatedNutrientProgressBarWidget),
      );
      expect(progressBar.percent, closeTo(0.0, 0.01));
    });

    testWidgets('handles zero goal gracefully', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 5.0,
        hoursGoal: 0,
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
        hoursSlept: 7.5,
        hoursGoal: 8,
        onTap: () => tapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });

    testWidgets('has background image decoration', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hoursSlept: 7.5,
        hoursGoal: 8,
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
              assetImage.assetName == 'assets/images/sleep_bkg.jpg') {
            foundBkg = true;
          }
        }
      }
      expect(foundBkg, isTrue);
    });
  });
}
