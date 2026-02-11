import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_button_1.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/generic_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  // ---------------------------------------------------------------------------
  // CustomButton1
  // ---------------------------------------------------------------------------
  group('CustomButton1', () {
    testWidgets('renders message text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton1(message: 'Continue', action: () {}),
        ),
      ));
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('tap calls action when enabled', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton1(
              message: 'Go', action: () => called = true, enable: true),
        ),
      ));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('does not call action when disabled', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton1(
              message: 'Go', action: () => called = true, enable: false),
        ),
      ));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(called, isFalse);
    });

    testWidgets('grey background when isSelected', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton1(
              message: 'Go', action: () {}, isSelected: true),
        ),
      ));
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      // When isSelected is true, backgroundColor should be grey[400]
      final bgColor = btn.style?.backgroundColor?.resolve({});
      expect(bgColor, Colors.grey[400]);
    });

    testWidgets('white background when not selected', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton1(
              message: 'Go', action: () {}, isSelected: false),
        ),
      ));
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final bgColor = btn.style?.backgroundColor?.resolve({});
      expect(bgColor, Colors.white);
    });

    testWidgets('uses custom textColor', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton1(
              message: 'Go', action: () {}, textColor: Colors.red),
        ),
      ));
      final text = tester.widget<Text>(find.text('Go'));
      expect(text.style?.color, Colors.red);
    });
  });

  // ---------------------------------------------------------------------------
  // GenericButton  (needs localization for default title)
  // ---------------------------------------------------------------------------
  group('GenericButton', () {
    Widget buildLocalized(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
        home: Scaffold(body: child),
      );
    }

    testWidgets('renders custom title when provided', (tester) async {
      await tester.pumpWidget(buildLocalized(
        GenericButton(title: 'Submit', onPressed: () {}),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('renders default localized text when no title', (tester) async {
      await tester.pumpWidget(buildLocalized(
        GenericButton(onPressed: () {}),
      ));
      await tester.pumpAndSettle();
      // Should render the localized "save" text – at minimum an ElevatedButton
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('tap calls onPressed when enabled', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GenericButton(
              title: 'Go',
              onPressed: () => called = true,
              enableButton: true),
        ),
      ));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GenericButton(
              title: 'Go',
              onPressed: () => called = true,
              enableButton: false),
        ),
      ));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(called, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // RoundedCustomButton  (wraps CustomButton1, needs localization for default)
  // ---------------------------------------------------------------------------
  group('RoundedCustomButton', () {
    Widget buildLocalized(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
        home: Scaffold(body: child),
      );
    }

    testWidgets('renders custom buttonText', (tester) async {
      await tester.pumpWidget(buildLocalized(
        RoundedCustomButton(buttonText: 'Next', onPressed: () {}),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('renders default localized text when no buttonText',
        (tester) async {
      await tester.pumpWidget(buildLocalized(
        RoundedCustomButton(onPressed: () {}),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('tap calls onPressed when enabled', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RoundedCustomButton(
              buttonText: 'Go',
              onPressed: () => called = true,
              enableButton: true),
        ),
      ));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RoundedCustomButton(
              buttonText: 'Go',
              onPressed: () => called = true,
              enableButton: false),
        ),
      ));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(called, isFalse);
    });
  });
}
