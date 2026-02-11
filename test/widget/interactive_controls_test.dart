import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/square_checkbox.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_checkbox_box.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_radio_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/radio_button_with_text.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/centered_icon_box.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/selectable_option.dart';

void main() {
  // ---------------------------------------------------------------------------
  // SquareCheckbox
  // ---------------------------------------------------------------------------
  group('SquareCheckbox', () {
    testWidgets('renders an InkWell for tapping', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SquareCheckbox(isChecked: false, onChanged: () {}),
        ),
      ));
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('tap calls onChanged callback', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SquareCheckbox(isChecked: false, onChanged: () => called = true),
        ),
      ));
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('checked state shows colored inner container', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SquareCheckbox(isChecked: true, onChanged: () {}),
        ),
      ));

      final blueInner = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          final d = w.decoration as BoxDecoration;
          return d.color == Colors.blue &&
              d.shape == BoxShape.rectangle &&
              d.borderRadius == const BorderRadius.all(Radius.circular(2));
        }
        return false;
      });
      expect(blueInner, findsOneWidget);
    });

    testWidgets('unchecked state shows transparent inner container',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SquareCheckbox(isChecked: false, onChanged: () {}),
        ),
      ));

      final transparentInner = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          final d = w.decoration as BoxDecoration;
          return d.color == Colors.transparent &&
              d.shape == BoxShape.rectangle &&
              d.borderRadius == const BorderRadius.all(Radius.circular(2));
        }
        return false;
      });
      expect(transparentInner, findsOneWidget);
    });

    testWidgets('uses custom color when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SquareCheckbox(
              isChecked: true, onChanged: () {}, color: Colors.red),
        ),
      ));

      final redInner = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          final d = w.decoration as BoxDecoration;
          return d.color == Colors.red &&
              d.shape == BoxShape.rectangle &&
              d.borderRadius == const BorderRadius.all(Radius.circular(2));
        }
        return false;
      });
      expect(redInner, findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // TextCheckboxBox
  // ---------------------------------------------------------------------------
  group('TextCheckboxBox', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextCheckboxBox(
              title: 'Gluten Free',
              checkboxValue: false,
              onChangedCheckbox: () {}),
        ),
      ));
      expect(find.text('Gluten Free'), findsOneWidget);
    });

    testWidgets('checkbox is checked when checkboxValue is true',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextCheckboxBox(
              title: 'X', checkboxValue: true, onChangedCheckbox: () {}),
        ),
      ));
      final cb = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.value, isTrue);
    });

    testWidgets('checkbox is unchecked when checkboxValue is false',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextCheckboxBox(
              title: 'X', checkboxValue: false, onChangedCheckbox: () {}),
        ),
      ));
      final cb = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.value, isFalse);
    });

    testWidgets('tapping checkbox calls onChangedCheckbox', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextCheckboxBox(
              title: 'X',
              checkboxValue: false,
              onChangedCheckbox: () => called = true),
        ),
      ));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('renders a divider', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextCheckboxBox(
              title: 'X', checkboxValue: false, onChangedCheckbox: () {}),
        ),
      ));
      expect(find.byType(Divider), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // TextRadioButton
  // ---------------------------------------------------------------------------
  group('TextRadioButton', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextRadioButton(
              title: 'Male', isSelected: false, onPressed: () {}),
        ),
      ));
      expect(find.text('Male'), findsOneWidget);
    });

    testWidgets('renders inside a Card', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextRadioButton(
              title: 'Male', isSelected: false, onPressed: () {}),
        ),
      ));
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('tap calls onPressed callback', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextRadioButton(
              title: 'Male', isSelected: false, onPressed: () => called = true),
        ),
      ));
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('selected state shows black inner circle', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextRadioButton(
              title: 'Male', isSelected: true, onPressed: () {}),
        ),
      ));

      final blackCircle = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          final d = w.decoration as BoxDecoration;
          return d.shape == BoxShape.circle && d.color == Colors.black;
        }
        return false;
      });
      expect(blackCircle, findsOneWidget);
    });

    testWidgets('unselected state shows no black inner circle', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextRadioButton(
              title: 'Male', isSelected: false, onPressed: () {}),
        ),
      ));

      final blackCircle = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          final d = w.decoration as BoxDecoration;
          return d.shape == BoxShape.circle && d.color == Colors.black;
        }
        return false;
      });
      expect(blackCircle, findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // RadioButtonWithText  (uses Expanded → must be in a Row / Flex)
  // ---------------------------------------------------------------------------
  group('RadioButtonWithText', () {
    Widget wrap(Widget child) =>
        MaterialApp(home: Scaffold(body: Row(children: [child])));

    testWidgets('renders text', (tester) async {
      await tester.pumpWidget(wrap(
        RadioButtonWithText(
            text: 'Option A',
            value: 1,
            groupValue: 0,
            onConversionFactorChange: (_) {}),
      ));
      expect(find.text('Option A'), findsOneWidget);
    });

    testWidgets('radio is selected when value equals groupValue',
        (tester) async {
      await tester.pumpWidget(wrap(
        RadioButtonWithText(
            text: 'A',
            value: 1,
            groupValue: 1,
            onConversionFactorChange: (_) {}),
      ));
      final radioFinder = find.byWidgetPredicate((w) => w is Radio);
      final radio = tester.widget(radioFinder) as Radio;
      expect(radio.value, radio.groupValue);
    });

    testWidgets('radio is not selected when value differs from groupValue',
        (tester) async {
      await tester.pumpWidget(wrap(
        RadioButtonWithText(
            text: 'A',
            value: 1,
            groupValue: 2,
            onConversionFactorChange: (_) {}),
      ));
      final radioFinder = find.byWidgetPredicate((w) => w is Radio);
      final radio = tester.widget(radioFinder) as Radio;
      expect(radio.value, isNot(radio.groupValue));
    });

    testWidgets('tap calls onConversionFactorChange with value',
        (tester) async {
      int? received;
      await tester.pumpWidget(wrap(
        RadioButtonWithText(
            text: 'A',
            value: 42,
            groupValue: 0,
            onConversionFactorChange: (v) => received = v),
      ));
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(received, 42);
    });
  });

  // ---------------------------------------------------------------------------
  // CenteredIconBox
  // ---------------------------------------------------------------------------
  group('CenteredIconBox', () {
    testWidgets('renders the given icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CenteredIconBox(
              icon: Icons.star, colorSelected: Colors.blue, onClick: () {}),
        ),
      ));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('tap calls onClick callback', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CenteredIconBox(
              icon: Icons.star,
              colorSelected: Colors.blue,
              onClick: () => called = true),
        ),
      ));
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('icon is white when selected', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CenteredIconBox(
              icon: Icons.star,
              colorSelected: Colors.blue,
              onClick: () {},
              isSelected: true),
        ),
      ));
      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, Colors.white);
    });

    testWidgets('icon is black when not selected', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CenteredIconBox(
              icon: Icons.star,
              colorSelected: Colors.blue,
              onClick: () {},
              isSelected: false),
        ),
      ));
      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, Colors.black);
    });
  });

  // ---------------------------------------------------------------------------
  // SelectableOption
  // ---------------------------------------------------------------------------
  group('SelectableOption', () {
    testWidgets('renders name text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SelectableOption(
              selectedOption: 0, name: 'Muscle Gain', id: 1, onTap: (_) {}),
        ),
      ));
      expect(find.text('Muscle Gain'), findsOneWidget);
    });

    testWidgets('shows amber background when selected', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SelectableOption(
              selectedOption: 1, name: 'Muscle Gain', id: 1, onTap: (_) {}),
        ),
      ));

      final amber = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          return (w.decoration as BoxDecoration).color == Colors.amber;
        }
        return false;
      });
      expect(amber, findsOneWidget);
    });

    testWidgets('shows transparent background when not selected',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SelectableOption(
              selectedOption: 0, name: 'Muscle Gain', id: 1, onTap: (_) {}),
        ),
      ));

      final transparent = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          final d = w.decoration as BoxDecoration;
          return d.color == Colors.transparent && d.border != null;
        }
        return false;
      });
      expect(transparent, findsOneWidget);
    });

    testWidgets('tap calls onTap with id', (tester) async {
      dynamic receivedId;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SelectableOption(
              selectedOption: 0,
              name: 'Muscle Gain',
              id: 7,
              onTap: (id) => receivedId = id),
        ),
      ));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(receivedId, 7);
    });
  });
}
