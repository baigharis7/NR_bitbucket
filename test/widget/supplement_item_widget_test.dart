import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/supplement_item_widget.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

void main() {
  Widget buildTestWidget({
    String title = 'Vitamin C',
    String amount = '500',
    List<String> units = const ['mg', 'g', 'mcg'],
    String? unit = 'mg',
    VoidCallback? onRemoveItem,
    Function(String)? onChangeAmount,
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
          child: SupplementItemWidget(
            title: title,
            amount: amount,
            units: units,
            unit: unit,
            onRemoveItem: onRemoveItem ?? () {},
            onChangeAmount: onChangeAmount ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('SupplementItemWidget', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildTestWidget(title: 'Creatine'));
      await tester.pumpAndSettle();
      expect(find.text('Creatine'), findsOneWidget);
    });

    testWidgets('shows amount in text field', (tester) async {
      await tester.pumpWidget(buildTestWidget(amount: '250'));
      await tester.pumpAndSettle();

      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.controller?.text, '250');
    });

    testWidgets('shows error styling when amount is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(amount: ''));
      await tester.pumpAndSettle();

      // When amount is empty, container gets red border and white65 bg
      final errorContainer = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          final d = w.decoration as BoxDecoration;
          return d.color == AppColors.white65Percent && d.border != null;
        }
        return false;
      });
      expect(errorContainer, findsOneWidget);
    });

    testWidgets('shows normal styling when amount is not empty',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(amount: '500'));
      await tester.pumpAndSettle();

      final normalContainer = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          final d = w.decoration as BoxDecoration;
          return d.color == AppColors.white85Percent && d.border == null;
        }
        return false;
      });
      expect(normalContainer, findsOneWidget);
    });

    testWidgets('tap remove icon calls onRemoveItem', (tester) async {
      bool called = false;
      await tester.pumpWidget(
          buildTestWidget(onRemoveItem: () => called = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.cancel_outlined));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('text change calls onChangeAmount', (tester) async {
      String? received;
      await tester.pumpWidget(
          buildTestWidget(onChangeAmount: (v) => received = v));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '999');
      await tester.pumpAndSettle();
      expect(received, '999');
    });

    testWidgets('renders dropdown with unit options', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        units: ['mg', 'g', 'mcg'],
        unit: 'mg',
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButton<String>), findsOneWidget);
      // Selected unit should be visible
      expect(find.text('mg'), findsOneWidget);
    });
  });
}
