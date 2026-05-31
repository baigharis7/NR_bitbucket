import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/date_picker_bar.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
    await initializeDateFormatting('en', null);
  });

  Widget buildTestWidget({
    required DateTime selectedDateTime,
    required Function(DateTime) onChangeDate,
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
        body: DatePickerBar(
          selectedDateTime: selectedDateTime,
          onChangeDate: onChangeDate,
        ),
      ),
    );
  }

  group('DatePickerBar', () {
    testWidgets('shows "Today" when selectedDateTime is today',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDateTime: DateTime.now(),
        onChangeDate: (_) {},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('shows formatted date when not today', (tester) async {
      final pastDate = DateTime(2026, 1, 15);
      final formattedDate = DateFormat('dd MMM yyyy').format(pastDate);

      await tester.pumpWidget(buildTestWidget(
        selectedDateTime: pastDate,
        onChangeDate: (_) {},
      ));
      await tester.pumpAndSettle();

      expect(find.text(formattedDate), findsOneWidget);
    });

    testWidgets('previous day button calls onChangeDate with day - 1',
        (tester) async {
      DateTime? receivedDate;
      final selectedDate = DateTime(2026, 2, 5);

      await tester.pumpWidget(buildTestWidget(
        selectedDateTime: selectedDate,
        onChangeDate: (date) => receivedDate = date,
      ));
      await tester.pumpAndSettle();

      // Tap left arrow
      await tester.tap(find.byIcon(Icons.arrow_left));
      await tester.pumpAndSettle();

      expect(receivedDate, isNotNull);
      expect(receivedDate!.day, 4);
      expect(receivedDate!.month, 2);
      expect(receivedDate!.year, 2026);
    });

    testWidgets('next day button calls onChangeDate with day + 1',
        (tester) async {
      DateTime? receivedDate;
      final selectedDate = DateTime(2026, 2, 5);

      await tester.pumpWidget(buildTestWidget(
        selectedDateTime: selectedDate,
        onChangeDate: (date) => receivedDate = date,
      ));
      await tester.pumpAndSettle();

      // Tap right arrow
      await tester.tap(find.byIcon(Icons.arrow_right));
      await tester.pumpAndSettle();

      expect(receivedDate, isNotNull);
      expect(receivedDate!.day, 6);
      expect(receivedDate!.month, 2);
      expect(receivedDate!.year, 2026);
    });

    testWidgets('next day button is visually disabled on today',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedDateTime: DateTime.now(),
        onChangeDate: (_) {},
      ));
      await tester.pumpAndSettle();

      // The right arrow icon should be grey when today
      final rightIcon = tester.widget<Icon>(find.byIcon(Icons.arrow_right));
      expect(rightIcon.color, Colors.grey);
    });

    testWidgets('next day button does NOT call callback on today',
        (tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(buildTestWidget(
        selectedDateTime: DateTime.now(),
        onChangeDate: (_) => callbackCalled = true,
      ));
      await tester.pumpAndSettle();

      // Tap right arrow (should be no-op since it's today)
      await tester.tap(find.byIcon(Icons.arrow_right));
      await tester.pumpAndSettle();

      expect(callbackCalled, false);
    });

    testWidgets('renders month abbreviation in Spanish when locale is es',
        (tester) async {
      // January = "Jan" in EN, "ene" in ES. Picking January catches the
      // month-name regression even though e.g. May happens to look the
      // same in both languages.
      final januaryDate = DateTime(2026, 1, 15);

      await tester.pumpWidget(buildTestWidget(
        selectedDateTime: januaryDate,
        onChangeDate: (_) {},
        locale: const Locale('es'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('15 ene 2026'), findsOneWidget);
      expect(find.text('15 Jan 2026'), findsNothing);
    });

    testWidgets('renders month abbreviation in English when locale is en',
        (tester) async {
      final januaryDate = DateTime(2026, 1, 15);

      await tester.pumpWidget(buildTestWidget(
        selectedDateTime: januaryDate,
        onChangeDate: (_) {},
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('15 Jan 2026'), findsOneWidget);
    });
  });
}
