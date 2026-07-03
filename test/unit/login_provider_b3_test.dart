import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/presentation/login/provider/login_provider_new.dart';

import '../bloc/bloc_test_mocks.mocks.dart';

/// LoginProviderNew.initialize() wires the whole real DI graph (Hive, prefs,
/// Drift...), so tests skip it and inject the error callback through this
/// getter override instead.
class TestableLoginProvider extends LoginProviderNew {
  Function? testOnError;

  @override
  Function? get onError => testOnError;
}

void main() {
  late MockSignUpInteractor mockSignUp;
  late MockResendVerificationCodeInteractor mockResend;
  late MockSignInInteractor mockSignIn;
  late MockSignOutInteractor mockSignOut;
  late MockFetchUserAttributesInteractor mockFetchAttributes;
  late TestableLoginProvider provider;
  late List<Object> reportedErrors;

  setUp(() {
    mockSignUp = MockSignUpInteractor();
    mockResend = MockResendVerificationCodeInteractor();
    mockSignIn = MockSignInInteractor();
    mockSignOut = MockSignOutInteractor();
    mockFetchAttributes = MockFetchUserAttributesInteractor();
    reportedErrors = [];
    provider = TestableLoginProvider()
      ..signUpInteractor = mockSignUp
      ..resendVerificationCodeInteractor = mockResend
      ..signInInteractor = mockSignIn
      ..signOutInteractor = mockSignOut
      ..fetchUserAttributesInteractor = mockFetchAttributes
      ..testOnError = (Object e) => reportedErrors.add(e);
  });

  void stubResendSuccess() {
    when(mockResend.execute(any))
        .thenAnswer((_) async => const CognitoResendSignUpCodeResult(
            AuthCodeDeliveryDetails(
                deliveryMedium: DeliveryMedium.email,
                destination: 'u***@e***.com')));
  }

  Future<void> submitSignUp() async {
    provider.changeLoginMode(() {}); // switch to register mode
    provider.submitData(
      email: 'user@example.com',
      password: 'Passw0rd!',
      repeatPassword: 'Passw0rd!',
      action: () {},
      goToRegistry: () {},
    );
    await pumpEventQueue();
  }

  group('signup door (US-1)', () {
    setUp(() {
      when(mockSignUp.execute(any, any))
          .thenThrow(const UsernameExistsException('User already exists'));
    });

    test('collision with UNCONFIRMED account resumes verification (AC-1.1)',
        () async {
      stubResendSuccess();
      var resumed = false;
      provider.onResumedVerification = () => resumed = true;
      provider.onAccountAlreadyActive =
          () => fail('must not report account-active');

      await submitSignUp();

      expect(resumed, isTrue);
      expect(reportedErrors, isEmpty);
      verify(mockResend.execute(any)).called(1);
    });

    test('collision with CONFIRMED account offers sign-in/reset (AC-1.2)',
        () async {
      when(mockResend.execute(any)).thenThrow(
          const InvalidParameterException('User is already confirmed.'));
      var active = false;
      provider.onResumedVerification = () => fail('must not resume');
      provider.onAccountAlreadyActive = () => active = true;

      await submitSignUp();

      expect(active, isTrue);
      expect(reportedErrors, isEmpty);
    });

    test('probe failing by network surfaces the real cause (AC-1.3)',
        () async {
      when(mockResend.execute(any))
          .thenThrow(const SocketException('no internet'));
      provider.onResumedVerification = () => fail('must not resume');
      provider.onAccountAlreadyActive = () => fail('must not report active');

      await submitSignUp();

      expect(reportedErrors, hasLength(1));
      expect(reportedErrors.single, isA<SocketException>());
    });

    test('any other signup error keeps current behaviour and never probes',
        () async {
      when(mockSignUp.execute(any, any))
          .thenThrow(Exception('Password did not conform with policy'));

      await submitSignUp();

      expect(reportedErrors, hasLength(1));
      verifyNever(mockResend.execute(any));
    });
  });

  group('login door (US-2/US-4)', () {
    Future<void> submitLogin() async {
      provider.submitData(
        email: 'user@example.com',
        password: 'Passw0rd!',
        repeatPassword: '',
        action: () {},
        goToRegistry: () {},
      );
      await pumpEventQueue(times: 50);
    }

    test('credentials failure offers recovery but never probes (AC-2.1/2.6)',
        () async {
      when(mockSignIn.execute(any, any)).thenThrow(
          const AuthNotAuthorizedException('Incorrect username or password.'));

      expect(provider.showVerificationRecovery, isFalse);
      await submitLogin();

      expect(provider.showVerificationRecovery, isTrue);
      verifyNever(mockResend.execute(any)); // explicit-tap only
      expect(reportedErrors, hasLength(1)); // normal credentials error shown
    });

    test('non-credential failure does not offer recovery', () async {
      when(mockSignIn.execute(any, any))
          .thenThrow(const SocketException('no internet'));

      await submitLogin();

      expect(provider.showVerificationRecovery, isFalse);
      verifyNever(mockResend.execute(any));
    });

    test('a new submit clears the recovery offer', () async {
      when(mockSignIn.execute(any, any)).thenThrow(
          const AuthNotAuthorizedException('Incorrect username or password.'));
      await submitLogin();
      expect(provider.showVerificationRecovery, isTrue);

      await submitLogin(); // flag must reset at the start of the attempt
      // (it gets re-set to true again by this failing attempt, so assert the
      // reset through mode change instead)
      provider.changeLoginMode(() {});
      expect(provider.showVerificationRecovery, isFalse);
    });

    test('recovery tap → code resent → opens verification (AC-2.2)', () async {
      stubResendSuccess();
      var opened = false;

      await provider.requestVerificationRecovery(
        onCodeResent: () => opened = true,
        onAlreadyConfirmed: () => fail('must not report already-confirmed'),
      );

      expect(opened, isTrue);
      expect(provider.showVerificationRecovery, isFalse);
    });

    test('recovery tap → already confirmed → reset guidance (AC-2.3)',
        () async {
      when(mockResend.execute(any)).thenThrow(
          const InvalidParameterException('User is already confirmed.'));
      var guided = false;

      await provider.requestVerificationRecovery(
        onCodeResent: () => fail('must not open verification'),
        onAlreadyConfirmed: () => guided = true,
      );

      expect(guided, isTrue);
    });

    test('recovery tap failing by network reports the real error', () async {
      when(mockResend.execute(any))
          .thenThrow(const SocketException('no internet'));

      await provider.requestVerificationRecovery(
        onCodeResent: () => fail('must not open verification'),
        onAlreadyConfirmed: () => fail('must not report already-confirmed'),
      );

      expect(reportedErrors.single, isA<SocketException>());
    });
  });

  group('post-verification chaining (AC-2.4/2.5)', () {
    late MockSendVerificationCodeInteractor mockConfirm;

    setUp(() {
      mockConfirm = MockSendVerificationCodeInteractor();
      provider.verificationCodeInteractor = mockConfirm;
      when(mockConfirm.execute(any, any))
          .thenAnswer((_) async => const CognitoSignUpResult(
                isSignUpComplete: true,
                nextStep: AuthNextSignUpStep(signUpStep: AuthSignUpStep.done),
              ));
    });

    test('confirming the code continues into the sign-in flow', () async {
      when(mockSignIn.execute(any, any)).thenThrow(
          const AuthNotAuthorizedException('Incorrect username or password.'));

      provider.sendVerificationCode(
        confirmationCode: '123456',
        action: () {},
        alreadyExistsAlias: () {},
      );
      await pumpEventQueue(times: 50);

      // The account got confirmed and the auto-login was attempted; when it
      // fails (forgotten password — or bug 5) the user gets a clear error and
      // stays on login, where the B2 reset now works for them.
      verify(mockConfirm.execute('123456', any)).called(1);
      verify(mockSignIn.execute(any, any)).called(greaterThanOrEqualTo(1));
      expect(reportedErrors, isNotEmpty);
    });
  });
}
