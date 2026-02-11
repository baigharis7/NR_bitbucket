import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/explaining_card.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/nutrient_row.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_info_card.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/horizontal_bar_widget.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

void main() {
  // ---------------------------------------------------------------------------
  // ExplainingCard
  // ---------------------------------------------------------------------------
  group('ExplainingCard', () {
    testWidgets('renders upperText', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExplainingCard(upperText: 'Welcome to the app'),
        ),
      ));
      expect(find.text('Welcome to the app'), findsOneWidget);
    });

    testWidgets('shows close icon when onHideCard is provided',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExplainingCard(upperText: 'Hi', onHideCard: () {}),
        ),
      ));
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('hides close icon when onHideCard is null', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExplainingCard(upperText: 'Hi'),
        ),
      ));
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('shows button when buttonText is provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExplainingCard(
            upperText: 'Hi',
            buttonText: 'Add Food',
            onPressedButton: () {},
          ),
        ),
      ));
      expect(find.text('Add Food'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline_sharp), findsOneWidget);
    });

    testWidgets('hides button when buttonText is null', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExplainingCard(upperText: 'Hi'),
        ),
      ));
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('close icon tap calls onHideCard', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExplainingCard(
              upperText: 'Hi', onHideCard: () => called = true),
        ),
      ));
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('button tap calls onPressedButton', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExplainingCard(
            upperText: 'Hi',
            buttonText: 'Add',
            onPressedButton: () => called = true,
          ),
        ),
      ));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('shows lowerText when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExplainingCard(
            upperText: 'Top',
            lowerText: 'Bottom info',
          ),
        ),
      ));
      expect(find.text('Bottom info'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // NutrientRow
  // ---------------------------------------------------------------------------
  group('NutrientRow', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NutrientRow(label: 'Protein', value: '25 g'),
        ),
      ));
      expect(find.text('Protein'), findsOneWidget);
    });

    testWidgets('renders value', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NutrientRow(label: 'Protein', value: '25 g'),
        ),
      ));
      expect(find.text('25 g'), findsOneWidget);
    });

    testWidgets('shows a divider', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NutrientRow(label: 'Protein', value: '25 g'),
        ),
      ));
      expect(find.byType(Divider), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // ItemInfoCard  (tested without asset images to avoid Image.asset issues)
  // ---------------------------------------------------------------------------
  group('ItemInfoCard', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ItemInfoCard(title: 'Chicken Breast'),
        ),
      ));
      expect(find.text('Chicken Breast'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ItemInfoCard(title: 'Chicken Breast', subtitle: '200 g'),
        ),
      ));
      expect(find.text('200 g'), findsOneWidget);
    });

    testWidgets('shows empty SizedBox when subtitle is null', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ItemInfoCard(title: 'Chicken Breast'),
        ),
      ));
      // subtitle null → const SizedBox() used instead of Text
      expect(find.text('200 g'), findsNothing);
    });

    testWidgets('uses custom background color', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ItemInfoCard(title: 'X', color: Colors.red),
        ),
      ));

      final redCard = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          return (w.decoration as BoxDecoration).color == Colors.red;
        }
        return false;
      });
      expect(redCard, findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // HorizontalBarWidget
  // ---------------------------------------------------------------------------
  group('HorizontalBarWidget', () {
    testWidgets('FractionallySizedBox widthFactor matches fillBarValue',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HorizontalBarWidget(fillBarValue: 0.5),
        ),
      ));

      final fb = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fb.widthFactor, 0.5);
    });

    testWidgets('caps widthFactor at 1 when fillBarValue > 1',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HorizontalBarWidget(fillBarValue: 1.5),
        ),
      ));

      final fb = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fb.widthFactor, 1.0);
    });

    testWidgets('bar color is errorRed when fill >= 1', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HorizontalBarWidget(fillBarValue: 1.0),
        ),
      ));

      final innerBar = find.descendant(
        of: find.byType(FractionallySizedBox),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(innerBar.first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.errorRed);
    });

    testWidgets('bar color is mountainMeadow when fill < 1', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HorizontalBarWidget(fillBarValue: 0.5),
        ),
      ));

      final innerBar = find.descendant(
        of: find.byType(FractionallySizedBox),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(innerBar.first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.mountainMeadow);
    });

    testWidgets('zero fill produces widthFactor 0', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HorizontalBarWidget(fillBarValue: 0.0),
        ),
      ));

      final fb = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fb.widthFactor, 0.0);
    });
  });
}
