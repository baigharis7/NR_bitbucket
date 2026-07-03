import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/bloc/reset_password_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/view/reset_password_screen.dart';

import '../bloc/bloc_test_mocks.mocks.dart';

void main() {
  late MockLoginRepository mockLoginRepository;
  late ResetPasswordBloc bloc;

  const carriedEmail = 'user@example.com';

  /// Pumps a host app and navigates to ResetPasswordScreen passing the email
  /// as route argument, the way ForgottenPasswordScreen does.
  ///
  /// The mock and bloc are created HERE, inside the testWidgets body, so all
  /// their async callbacks run in the tester's fake-async zone. Creating them
  /// in setUp() binds those callbacks to the real clock and the dialog/timer
  /// flow becomes invisible to tester.pump.
  Future<void> pumpAndOpenScreen(WidgetTester tester) async {
    mockLoginRepository = MockLoginRepository();
    bloc = ResetPasswordBloc(loginRepository: mockLoginRepository);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
        routes: {
          ResetPasswordScreen.routeName: (_) => BlocProvider.value(
                value: bloc,
                child: const ResetPasswordScreen(),
              ),
          // Stub target for the post-success navigation; the real
          // LoginScreen drags in the whole app bootstrap.
          LoginScreen.routeName: (_) =>
              const Scaffold(body: Text('login-stub')),
        },
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.pushNamed(
              context,
              ResetPasswordScreen.routeName,
              arguments: carriedEmail,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> fillAndSubmitForm(WidgetTester tester) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Passw0rd!');
    await tester.enterText(fields.at(1), 'Passw0rd!');
    await tester.enterText(fields.at(2), '123456');
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();
  }

  group('ResetPasswordScreen', () {
    testWidgets('has no email field to re-type (AC-6.1)', (tester) async {
      await pumpAndOpenScreen(tester);

      // Only new password, repeat password and confirmation code remain.
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Email'), findsNothing);
    });

    testWidgets('confirmation code field is not obscured (C.2)',
        (tester) async {
      await pumpAndOpenScreen(tester);

      final codeField = tester.widget<TextField>(find.byType(TextField).at(2));
      expect(codeField.obscureText, isFalse);
    });

    testWidgets('confirms the reset against the carried email (AC-3.2)',
        (tester) async {
      await pumpAndOpenScreen(tester);
      when(mockLoginRepository.confirmResetPassword(any, any, any))
          .thenThrow(Exception('boom'));

      await fillAndSubmitForm(tester);

      verify(mockLoginRepository.confirmResetPassword(
        carriedEmail,
        'Passw0rd!', // the *new password* field, not the repeat one (C.3)
        '123456',
      )).called(1);
    });

    group('success navigation (AC-3.5)', () {
      Future<void> openAndSubmitSuccessfully(WidgetTester tester) async {
        await pumpAndOpenScreen(tester);
        when(mockLoginRepository.confirmResetPassword(any, any, any))
            .thenAnswer((_) async => const CognitoResetPasswordResult(
                  isPasswordReset: true,
                  nextStep: ResetPasswordStep(
                      updateStep: AuthResetPasswordStep.done),
                ));
        await fillAndSubmitForm(tester);
      }

      testWidgets('auto-dismisses the dialog and lands on login',
          (tester) async {
        await openAndSubmitSuccessfully(tester);
        expect(find.byType(ConfirmationDialog), findsOneWidget);
        expect(find.text('login-stub'), findsNothing);

        // Past the 2s auto-dismiss, plus the pop/navigation animations.
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(find.text('login-stub'), findsOneWidget);
      });

      testWidgets(
          'dismissing the dialog early still lands (and stays) on login',
          (tester) async {
        await openAndSubmitSuccessfully(tester);
        expect(find.byType(ConfirmationDialog), findsOneWidget);

        // User taps the barrier before the 2s auto-dismiss fires.
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();
        expect(find.text('login-stub'), findsOneWidget);

        // The stale timer must not pop the login route afterwards.
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('login-stub'), findsOneWidget);
      });
    });
  });
}
