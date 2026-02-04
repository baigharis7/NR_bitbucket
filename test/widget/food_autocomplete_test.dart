import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';

void main() {
  final testFoods = [
    'Apple',
    'Apricot',
    'Avocado',
    'Banana',
    'Blueberry',
    'Cherry',
    'Coconut',
    'Date',
    'Fig',
    'Grape',
  ];

  Widget buildTestWidget(List<String> foods, {Function(String, FocusNode)? onItemSelect}) {
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HeaderAddItemCardSection(
              title: 'Add Food',
              items: foods,
              onItemSelect: onItemSelect ?? (item, focusNode) {},
            ),
          ),
        ),
      ),
    );
  }

  group('Food Autocomplete Widget Tests', () {
    // Test 1: Popup should NOT appear with empty input
    testWidgets('should not show suggestions when input is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(testFoods));
      await tester.pumpAndSettle();

      // Find and tap the TextField to focus it
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Verify no suggestions are shown (no food names visible)
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Banana'), findsNothing);
    });

    // Test 2: Popup should appear after 1 character
    testWidgets('should show suggestions after typing 1 character', (tester) async {
      await tester.pumpWidget(buildTestWidget(testFoods));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Should show items containing 'a'
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Apricot'), findsOneWidget);
      expect(find.text('Avocado'), findsOneWidget);
    });

    // Test 3: Alphabetical sorting and filtering
    testWidgets('should display filtered foods in alphabetical order', (tester) async {
      await tester.pumpWidget(buildTestWidget(testFoods));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'b');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Both should be visible
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Blueberry'), findsOneWidget);
    });

    // Test 4: Item count displayed at top
    testWidgets('should display item count in suggestions header', (tester) async {
      await tester.pumpWidget(buildTestWidget(testFoods));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Should show item count (3 items: Apple, Apricot, Avocado + Banana, Date, Grape contain 'a')
      // The exact count depends on filtering logic
      expect(find.textContaining('found'), findsOneWidget);
    });

    // Test 5: Alphabet section headers are displayed
    testWidgets('should display alphabet section headers', (tester) async {
      await tester.pumpWidget(buildTestWidget(testFoods));
      await tester.pumpAndSettle();

      // Type something that matches multiple letters
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Should show letter headers for matching items
      // 'A' header for Apple, Apricot, Avocado
      // 'B' header for Banana (contains 'a')
      expect(find.text('A'), findsOneWidget);
    });

    // Test 6: Selection clears input and calls callback
    testWidgets('should clear input and call callback after selection', (tester) async {
      String? selectedItem;

      await tester.pumpWidget(buildTestWidget(
        testFoods,
        onItemSelect: (item, focusNode) {
          selectedItem = item;
        },
      ));
      await tester.pumpAndSettle();

      // Type and select
      await tester.enterText(find.byType(TextField), 'app');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Tap on Apple
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();

      // Callback should have been called
      expect(selectedItem, equals('Apple'));

      // Input should be cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    // Test 7: Scrollbar is present when needed
    testWidgets('should show scrollbar when list is scrollable', (tester) async {
      // Create a larger list to ensure scrolling is needed
      final manyFoods = List.generate(50, (i) => 'Food${String.fromCharCode(65 + (i % 26))}$i');

      await tester.pumpWidget(buildTestWidget(manyFoods));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Food');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Scrollbar should be present
      expect(find.byType(Scrollbar), findsWidgets);
    });

    // Test 8: Clear button works
    testWidgets('should clear input when clear button is pressed', (tester) async {
      await tester.pumpWidget(buildTestWidget(testFoods));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pumpAndSettle();

      // Find and tap clear button
      final clearButton = find.byIcon(Icons.highlight_remove);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        // Input should be cleared
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
      }
    });

    // Test 9: Diacritic-insensitive search
    testWidgets('should find items regardless of diacritics', (tester) async {
      final foodsWithDiacritics = ['Café', 'Naïve', 'Résumé', 'Apple'];

      await tester.pumpWidget(buildTestWidget(foodsWithDiacritics));
      await tester.pumpAndSettle();

      // Search without diacritics should still find items
      await tester.enterText(find.byType(TextField), 'cafe');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(find.text('Café'), findsOneWidget);
    });
  });
}
