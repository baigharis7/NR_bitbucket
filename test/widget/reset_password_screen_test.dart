import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/bloc/reset_password_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/view/reset_password_screen.dart';

import '../bloc/bloc_test_mocks.mocks.dart';

void main() {
  late MockLoginRepository mockLoginRepository;
  late ResetPasswordBloc bloc;

  const carriedEmail = 'user@example.com';

  setUp(() {
    mockLoginRepository = MockLoginRepository();
    bloc = ResetPasswordBloc(loginRepository: mockLoginRepository);
  });

  tearDown(() => bloc.close());

  /// Pumps a host app and navigates to ResetPasswordScreen passing the email
  /// as route argument, the way ForgottenPasswordScreen does.
  Future<void> pumpAndOpenScreen(WidgetTester tester) async {
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

  group('ResetPasswordScreen', () {
    testWidgets('has no email field to re-type (AC-6.1)', (tester) async {
      await pumpAndOpenScreen(tester);

      // Only new password, repeat password and confirmation code remain.
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Email'), findsNothing);
    });

    testWidgets('confirms the reset against the carried email (AC-3.2)',
        (tester) async {
      when(mockLoginRepository.confirmResetPassword(any, any, any))
          .thenThrow(Exception('boom'));
      await pumpAndOpenScreen(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Passw0rd!');
      await tester.enterText(fields.at(1), 'Passw0rd!');
      await tester.enterText(fields.at(2), '123456');
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      verify(mockLoginRepository.confirmResetPassword(
        carriedEmail,
        any,
        '123456',
      )).called(1);
    });
  });
}
