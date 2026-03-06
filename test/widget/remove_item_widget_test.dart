import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/remove_item_widget.dart';

void main() {
  Widget buildTestWidget({
    required String description,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
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
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => RemoveItemWidget(
                  description: description,
                  onConfirm: onConfirm,
                  onCancel: onCancel,
                ),
              );
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    );
  }

  group('TS-BF0012: Delete logged item - Confirmation dialog', () {
    testWidgets('displays "Remove item" title and description',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        description: 'Remove Banana?',
        onConfirm: () {},
        onCancel: () {},
      ));
      await tester.pumpAndSettle();

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Title and description are shown
      expect(find.text('Remove item'), findsOneWidget);
      expect(find.text('Remove Banana?'), findsOneWidget);
    });

    testWidgets('displays Yes and No buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        description: 'Remove Apple?',
        onConfirm: () {},
        onCancel: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
    });

    testWidgets('tapping No calls onCancel', (tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(buildTestWidget(
        description: 'Remove Apple?',
        onConfirm: () {},
        onCancel: () => cancelCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(cancelCalled, isTrue);
    });

    testWidgets('tapping Yes calls onConfirm and closes dialog',
        (tester) async {
      bool confirmCalled = false;

      await tester.pumpWidget(buildTestWidget(
        description: 'Remove Apple?',
        onConfirm: () => confirmCalled = true,
        onCancel: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(confirmCalled, isTrue);
      // Dialog should be dismissed
      expect(find.text('Remove item'), findsNothing);
    });
  });
}
