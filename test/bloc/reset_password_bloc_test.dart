import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/error_type_strings.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/bloc/reset_password_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockLoginRepository mockLoginRepository;
  var finished = false;

  setUp(() {
    mockLoginRepository = MockLoginRepository();
  });

  ResetPasswordBloc buildBloc() => ResetPasswordBloc(
        loginRepository: mockLoginRepository,
      );

  ConfirmResetPasswordEventAction confirmAction() =>
      ConfirmResetPasswordEventAction(
        username: 'user@example.com',
        password: 'Passw0rd!',
        confirmationCode: '123456',
        onFinish: () => finished = true,
      );

  group('ResetPasswordBloc', () {
    blocTest<ResetPasswordBloc, ResetPasswordState>(
      'initial state is not loading with no error',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.onError, isNull);
      },
    );

    blocTest<ResetPasswordBloc, ResetPasswordState>(
      'wrong code emits error and does NOT call onFinish (AC-3.3)',
      build: () {
        finished = false;
        when(mockLoginRepository.confirmResetPassword(any, any, any))
            .thenThrow(Exception(ErrorTypStrings.INVALID_CODE));
        return buildBloc();
      },
      act: (bloc) => bloc.add(confirmAction()),
      expect: () => [
        isA<ResetPasswordState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ResetPasswordState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', isNotNull),
      ],
      verify: (_) => expect(finished, isFalse),
    );

    blocTest<ResetPasswordBloc, ResetPasswordState>(
      'success calls onFinish so the user is taken to login (AC-3.5)',
      build: () {
        finished = false;
        when(mockLoginRepository.confirmResetPassword(any, any, any))
            .thenAnswer((_) async => const CognitoResetPasswordResult(
                  isPasswordReset: true,
                  nextStep:
                      ResetPasswordStep(updateStep: AuthResetPasswordStep.done),
                ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(confirmAction()),
      expect: () => [
        isA<ResetPasswordState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ResetPasswordState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', isNull),
      ],
      verify: (bloc) {
        expect(finished, isTrue);
        verify(mockLoginRepository.confirmResetPassword(
                'user@example.com', 'Passw0rd!', '123456'))
            .called(1);
      },
    );
  });
}
