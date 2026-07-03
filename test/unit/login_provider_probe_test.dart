import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/error_type_strings.dart';
import 'package:nutrenaissance_flutter/presentation/login/provider/login_provider_new.dart';

import '../bloc/bloc_test_mocks.mocks.dart';

void main() {
  late MockResendVerificationCodeInteractor mockResendInteractor;
  late LoginProviderNew provider;

  setUp(() {
    mockResendInteractor = MockResendVerificationCodeInteractor();
    provider = LoginProviderNew()
      ..resendVerificationCodeInteractor = mockResendInteractor;
  });

  void stubResendThrow(Object error) {
    when(mockResendInteractor.execute(any)).thenThrow(error);
  }

  group('probeAccountState', () {
    test('resend succeeds → codeResent', () async {
      when(mockResendInteractor.execute(any))
          .thenAnswer((_) async => const CognitoResendSignUpCodeResult(
              AuthCodeDeliveryDetails(
                  deliveryMedium: DeliveryMedium.email,
                  destination: 'u***@e***.com')));

      expect((await provider.probeAccountState()).result, ProbeResult.codeResent);
    });

    test('already-confirmed account → alreadyConfirmed', () async {
      stubResendThrow(
          const InvalidParameterException('User is already confirmed.'));

      expect((await provider.probeAccountState()).result, ProbeResult.alreadyConfirmed);
    });

    test('other InvalidParameterException → unknown', () async {
      stubResendThrow(
          const InvalidParameterException('Invalid email address format.'));

      expect((await provider.probeAccountState()).result, ProbeResult.unknown);
    });

    test('resend limits → tooManyAttempts', () async {
      stubResendThrow(
          const LimitExceededException('Attempt limit exceeded, please try '
              'after some time.'));
      expect((await provider.probeAccountState()).result, ProbeResult.tooManyAttempts);

      stubResendThrow(const TooManyRequestsException('Too many requests'));
      expect((await provider.probeAccountState()).result, ProbeResult.tooManyAttempts);
    });

    test('daily email limit surfaced as wrapped message → tooManyAttempts',
        () async {
      stubResendThrow(Exception(ErrorTypStrings.DAILY_LIMIT_EXCEEDED));
      // Exception.message via dynamic access is how userError reads these too.
      expect((await provider.probeAccountState()).result, ProbeResult.tooManyAttempts);
    });

    test('connectivity failures → network', () async {
      stubResendThrow(const SocketException('no internet'));
      expect((await provider.probeAccountState()).result, ProbeResult.network);

      stubResendThrow(const NetworkException('device offline'));
      expect((await provider.probeAccountState()).result, ProbeResult.network);
    });

    test('anything else → unknown', () async {
      stubResendThrow(StateError('unexpected'));
      expect((await provider.probeAccountState()).result, ProbeResult.unknown);
    });
  });
}
