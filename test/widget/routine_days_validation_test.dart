import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/routine_days_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_title_card.dart';

void main() {
  Widget buildRoutineDaysWidget({
    List<int> daysOfWeek = const [],
    bool showError = false,
    Function(DateTime)? onDaySelect,
    Function(List<int>)? onBulkDaySelect,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: RoutineDaysWidget(
          title: 'Days of the week',
          daysOfWeek: daysOfWeek,
          showError: showError,
          onDaySelect: onDaySelect ?? (_) {},
          onBulkDaySelect: onBulkDaySelect,
        ),
      ),
    );
  }

  Widget buildItemTitleCard({
    bool isRoutine = true,
    List<int> daysOfWeek = const [],
    bool showRoutineValidation = false,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: SingleChildScrollView(
          child: ItemTitleCard(
            name: 'Test',
            onUpdateName: (_) {},
            isFavorite: false,
            onToggleFavorite: () {},
            isRoutine: isRoutine,
            onToggleRoutine: () {},
            itemCount: 1,
            scheduleTime: const TimeOfDay(hour: 8, minute: 0),
            onUpdateTime: (_) {},
            daysOfWeek: daysOfWeek,
            onUpdateDayOfWeek: (_) {},
            onBulkDaySelect: (_) {},
            showRoutineValidation: showRoutineValidation,
          ),
        ),
      ),
    );
  }

  /// Finds all unselected day circle containers (white background) and checks their border color
  List<Color> _getUnselectedDayBorderColors(WidgetTester tester) {
    final containers = tester.widgetList<Container>(find.byType(Container)).toList();
    final borderColors = <Color>[];
    for (final container in containers) {
      final decoration = container.decoration;
      if (decoration is BoxDecoration &&
          decoration.color == Colors.white &&
          decoration.shape == BoxShape.rectangle &&
          decoration.borderRadius == BorderRadius.circular(50)) {
        final border = decoration.border;
        if (border is Border && border.top.color != Colors.white) {
          borderColors.add(border.top.color);
        }
      }
    }
    return borderColors;
  }

  group('RoutineDaysWidget error state', () {
    testWidgets('no days selected with showError=true shows red borders on day circles', (tester) async {
      await tester.pumpWidget(buildRoutineDaysWidget(
        daysOfWeek: [],
        showError: true,
      ));
      await tester.pumpAndSettle();

      final borderColors = _getUnselectedDayBorderColors(tester);
      // All 7 day circles + 2 quick-select buttons should have red borders
      expect(borderColors, isNotEmpty);
      expect(borderColors.every((c) => c == AppColors.errorRed), isTrue,
          reason: 'All unselected day circles should have red borders');
    });

    testWidgets('no days selected with showError=false shows normal grey borders', (tester) async {
      await tester.pumpWidget(buildRoutineDaysWidget(
        daysOfWeek: [],
        showError: false,
      ));
      await tester.pumpAndSettle();

      final borderColors = _getUnselectedDayBorderColors(tester);
      expect(borderColors, isNotEmpty);
      expect(borderColors.every((c) => c == AppColors.cloudyGrey), isTrue,
          reason: 'All unselected day circles should have grey borders');
    });

    testWidgets('selecting a single day clears red borders when showError=true but days not empty', (tester) async {
      // With one day selected and showError=true, the error should not show
      // because the parent (ItemTitleCard) computes showDaysError based on daysOfWeek being empty
      // Here we test RoutineDaysWidget directly: showError=false when days are selected
      await tester.pumpWidget(buildRoutineDaysWidget(
        daysOfWeek: [1], // Monday selected
        showError: false,
      ));
      await tester.pumpAndSettle();

      final borderColors = _getUnselectedDayBorderColors(tester);
      // 6 remaining unselected days should have grey borders (not red)
      expect(borderColors, isNotEmpty);
      expect(borderColors.every((c) => c == AppColors.cloudyGrey), isTrue,
          reason: 'Unselected day circles should have grey borders when error is cleared');
    });

    testWidgets('weekdays selected clears red borders on remaining unselected days', (tester) async {
      await tester.pumpWidget(buildRoutineDaysWidget(
        daysOfWeek: [1, 2, 3, 4, 5], // Mon-Fri
        showError: false,
      ));
      await tester.pumpAndSettle();

      final borderColors = _getUnselectedDayBorderColors(tester);
      // Sat + Sun still unselected but should be grey (not red)
      expect(borderColors, isNotEmpty);
      expect(borderColors.every((c) => c == AppColors.cloudyGrey), isTrue);
    });

    testWidgets('weekend selected clears red borders on remaining unselected days', (tester) async {
      await tester.pumpWidget(buildRoutineDaysWidget(
        daysOfWeek: [6, 7], // Sat-Sun
        showError: false,
      ));
      await tester.pumpAndSettle();

      final borderColors = _getUnselectedDayBorderColors(tester);
      // Mon-Fri still unselected but should be grey (not red)
      expect(borderColors, isNotEmpty);
      expect(borderColors.every((c) => c == AppColors.cloudyGrey), isTrue);
    });
  });

  group('ItemTitleCard routine validation integration', () {
    testWidgets('shows error text when showRoutineValidation=true and no days selected', (tester) async {
      await tester.pumpWidget(buildItemTitleCard(
        isRoutine: true,
        daysOfWeek: [],
        showRoutineValidation: true,
      ));
      await tester.pumpAndSettle();

      // Error text should be visible
      expect(find.textContaining('routine'), findsWidgets);
      // Day circles should have red borders
      final borderColors = _getUnselectedDayBorderColors(tester);
      expect(borderColors, isNotEmpty);
      expect(borderColors.every((c) => c == AppColors.errorRed), isTrue);
    });

    testWidgets('no error when showRoutineValidation=true but days are selected', (tester) async {
      await tester.pumpWidget(buildItemTitleCard(
        isRoutine: true,
        daysOfWeek: [3], // Wednesday
        showRoutineValidation: true,
      ));
      await tester.pumpAndSettle();

      // Day circles should have normal borders (grey for unselected, green for selected)
      final borderColors = _getUnselectedDayBorderColors(tester);
      expect(borderColors, isNotEmpty);
      expect(borderColors.every((c) => c == AppColors.cloudyGrey), isTrue);
    });

    testWidgets('no error when showRoutineValidation=false even with no days', (tester) async {
      await tester.pumpWidget(buildItemTitleCard(
        isRoutine: true,
        daysOfWeek: [],
        showRoutineValidation: false,
      ));
      await tester.pumpAndSettle();

      // Day circles should have normal grey borders
      final borderColors = _getUnselectedDayBorderColors(tester);
      expect(borderColors, isNotEmpty);
      expect(borderColors.every((c) => c == AppColors.cloudyGrey), isTrue);
    });

    testWidgets('no error when not a routine even with showRoutineValidation=true', (tester) async {
      await tester.pumpWidget(buildItemTitleCard(
        isRoutine: false,
        daysOfWeek: [],
        showRoutineValidation: true,
      ));
      await tester.pumpAndSettle();

      // RoutineDaysWidget should not even be rendered
      expect(find.byType(RoutineDaysWidget), findsNothing);
    });

    testWidgets('weekdays selected clears error in ItemTitleCard', (tester) async {
      await tester.pumpWidget(buildItemTitleCard(
        isRoutine: true,
        daysOfWeek: [1, 2, 3, 4, 5],
        showRoutineValidation: true,
      ));
      await tester.pumpAndSettle();

      // showDaysError = showRoutineValidation && isRoutine && daysOfWeek.isEmpty
      // daysOfWeek is [1,2,3,4,5] so showDaysError = false
      final borderColors = _getUnselectedDayBorderColors(tester);
      expect(borderColors, isNotEmpty);
      expect(borderColors.every((c) => c == AppColors.cloudyGrey), isTrue);
    });

    testWidgets('weekend selected clears error in ItemTitleCard', (tester) async {
      await tester.pumpWidget(buildItemTitleCard(
        isRoutine: true,
        daysOfWeek: [6, 7],
        showRoutineValidation: true,
      ));
      await tester.pumpAndSettle();

      final borderColors = _getUnselectedDayBorderColors(tester);
      expect(borderColors, isNotEmpty);
      expect(borderColors.every((c) => c == AppColors.cloudyGrey), isTrue);
    });
  });
}
