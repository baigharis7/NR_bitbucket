import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_vertical_bar.dart';

void main() {
  Widget buildTestWidget({
    required double fractionToFill,
    double? width,
    Color? barColor,
    Color? backgroundColor,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 100,
          width: 100,
          child: FillVerticalBar(
            fractionToFill: fractionToFill,
            width: width,
            barColor: barColor,
            backgroundColor: backgroundColor,
          ),
        ),
      ),
    );
  }

  group('FillVerticalBar', () {
    testWidgets('renders FractionallySizedBox with given fractionToFill',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(fractionToFill: 0.75));
      await tester.pumpAndSettle();

      final fractionBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionBox.heightFactor, 0.75);
    });

    testWidgets('uses barColor when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(fractionToFill: 0.5, barColor: Colors.red),
      );
      await tester.pumpAndSettle();

      // The inner container (inside FractionallySizedBox) should have the bar color
      final fractionBox = find.byType(FractionallySizedBox);
      final innerContainer = find.descendant(
        of: fractionBox,
        matching: find.byType(Container),
      );
      expect(innerContainer, findsOneWidget);

      final container = tester.widget<Container>(innerContainer);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });

    testWidgets('uses default color (white30) when no barColor',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(fractionToFill: 0.5));
      await tester.pumpAndSettle();

      final fractionBox = find.byType(FractionallySizedBox);
      final innerContainer = find.descendant(
        of: fractionBox,
        matching: find.byType(Container),
      );

      final container = tester.widget<Container>(innerContainer);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white30);
    });

    testWidgets('uses given width', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(fractionToFill: 0.5, width: 25),
      );
      await tester.pumpAndSettle();

      // Find the outermost Container in the Row (has explicit width)
      final containers = find.byType(Container);
      bool foundWidth = false;
      for (final element in containers.evaluate()) {
        final widget = element.widget as Container;
        if (widget.constraints?.maxWidth == 25) {
          foundWidth = true;
          break;
        }
      }
      expect(foundWidth, true);
    });

    testWidgets('uses default width (15) when not specified', (tester) async {
      await tester.pumpWidget(buildTestWidget(fractionToFill: 0.5));
      await tester.pumpAndSettle();

      final containers = find.byType(Container);
      bool foundWidth = false;
      for (final element in containers.evaluate()) {
        final widget = element.widget as Container;
        if (widget.constraints?.maxWidth == 15) {
          foundWidth = true;
          break;
        }
      }
      expect(foundWidth, true);
    });
  });
}
