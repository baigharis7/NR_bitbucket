import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_field_general_quest.dart';

void main() {
  Widget buildTestWidget({
    String title = 'Test Field',
    required Function onChanged,
    bool isNumeric = false,
    double? value,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: TextFieldGeneralQuest(
            title: title,
            onChanged: onChanged,
            isNumeric: isNumeric,
            errorBorderColor: Colors.red,
            value: value,
          ),
        ),
      ),
    );
  }

  group('TextFieldGeneralQuest', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        title: 'Weight (kg)',
        onChanged: (_) {},
        value: null,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Weight (kg)'), findsOneWidget);
    });

    testWidgets('shows initial value when provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        onChanged: (_) {},
        value: 75.0,
      ));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '75.0');
    });

    testWidgets('shows empty field when value is 0 or negative',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        onChanged: (_) {},
        value: 0.0,
      ));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '');
    });

    testWidgets('numeric mode sets number keyboard', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        onChanged: (_) {},
        isNumeric: true,
        value: null,
      ));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.number);
    });

    testWidgets('text input triggers onChanged callback', (tester) async {
      String? receivedValue;

      await tester.pumpWidget(buildTestWidget(
        onChanged: (value) => receivedValue = value,
        value: null,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '180');
      await tester.pumpAndSettle();

      expect(receivedValue, '180');
    });

    testWidgets('clearing field sends empty string via callback', (tester) async {
      String? receivedValue;

      await tester.pumpWidget(buildTestWidget(
        onChanged: (value) => receivedValue = value,
        value: 75.0,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(receivedValue, '');
    });

    testWidgets('validator surfaces error text on form validate', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: TextFieldGeneralQuest(
              title: 'Weight',
              onChanged: (_) {},
              isNumeric: true,
              errorBorderColor: Colors.red,
              value: null,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Required'), findsOneWidget);
    });
  });
}
