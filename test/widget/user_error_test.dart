import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/error_type_strings.dart';

/// Mimics AuthException-like errors that expose a `.message` getter,
/// which is what `userError` matches on.
class _FakeAuthError {
  _FakeAuthError(this.message);
  final String message;

  @override
  String toString() => 'FakeAuthError($message)';
}

void main() {
  late BuildContext capturedContext;
  late AppLocalizations l10n;

  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    l10n = AppLocalizations.of(capturedContext)!;
  }

  group('userError', () {
    testWidgets('network errors resolve to the connectivity message',
        (tester) async {
      await pumpHost(tester);

      expect(
        userError(capturedContext, const SocketException('no internet')),
        l10n.connection_error_try_later,
      );
      expect(
        userError(
            capturedContext, Exception('SocketException: Failed host lookup')),
        l10n.connection_error_try_later,
      );
    });

    testWidgets('unknown errors resolve to the generic message, never the '
        'sign-in one', (tester) async {
      await pumpHost(tester);

      final unknowns = <Object>[
        Exception('Some new Amplify error we do not map'),
        StateError('unexpected null'),
        _FakeAuthError('Password did not conform with policy'),
      ];
      for (final error in unknowns) {
        final resolved = userError(capturedContext, error);
        expect(resolved, l10n.generic_error);
        expect(resolved, isNot(l10n.sign_in_error));
      }
    });

    testWidgets('known Cognito messages keep their specific mapping',
        (tester) async {
      await pumpHost(tester);

      expect(
        userError(
            capturedContext, _FakeAuthError(ErrorTypStrings.INVALID_CODE)),
        l10n.invalid_code,
      );
      expect(
        userError(capturedContext,
            _FakeAuthError(ErrorTypStrings.NOT_AUTORIZED_USER)),
        l10n.not_authorized_error,
      );
    });

    testWidgets('daily email limit resolves to too-many-attempts',
        (tester) async {
      await pumpHost(tester);

      expect(
        userError(capturedContext,
            _FakeAuthError(ErrorTypStrings.DAILY_LIMIT_EXCEEDED)),
        l10n.too_many_attempts,
      );
    });
  });
}
