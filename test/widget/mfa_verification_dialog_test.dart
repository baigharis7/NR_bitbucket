import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/mfa_verification_dialog.dart';

/// Regression tests for the signup confirmation-code dialog.
///
/// The bug: pressing "Accept" with an empty field used to silently close the
/// dialog, stranding the user mid-signup (a common cause of stuck UNCONFIRMED
/// accounts, since the verification code often lands in spam). The dialog must
/// now stay open and show an inline error on empty submit, and only forward a
/// non-empty code.
void main() {
  late TextEditingController controller;
  late List<String> submitted;
  late int resendCount;
  late int cancelCount;

  setUp(() {
    controller = TextEditingController();
    submitted = [];
    resendCount = 0;
    cancelCount = 0;
  });

  tearDown(() => controller.dispose());

  Future<void> pumpDialog(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: MfaVerificationDialog(
          controller: controller,
          onSubmit: submitted.add,
          onResend: () => resendCount++,
          onCancel: () => cancelCount++,
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('empty submit shows inline error and does not call onSubmit',
      (tester) async {
    await pumpDialog(tester);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(submitted, isEmpty);
    // Inline error visible — the dialog stayed open.
    expect(find.text('Confirmation code is empty'), findsOneWidget);
    expect(find.text('Account verification'), findsOneWidget);
  });

  testWidgets('non-empty submit forwards the code via onSubmit',
      (tester) async {
    await pumpDialog(tester);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(submitted, ['123456']);
    expect(find.text('Confirmation code is empty'), findsNothing);
  });

  testWidgets('typing clears a previously shown error', (tester) async {
    await pumpDialog(tester);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmation code is empty'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '1');
    await tester.pumpAndSettle();
    expect(find.text('Confirmation code is empty'), findsNothing);
  });

  testWidgets('resend and cancel forward to their callbacks', (tester) async {
    await pumpDialog(tester);

    await tester.tap(find.text('Send another code'));
    await tester.pumpAndSettle();
    expect(resendCount, 1);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(cancelCount, 1);
  });
}
