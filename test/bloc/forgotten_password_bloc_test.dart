import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/presentation/forgottenpassword/bloc/forgotten_password_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockLoginRepository mockLoginRepository;

  setUp(() {
    mockLoginRepository = MockLoginRepository();
  });

  ForgottenPasswordBloc buildBloc() => ForgottenPasswordBloc(
        loginRepository: mockLoginRepository,
      );

  group('ForgottenPasswordBloc', () {
    blocTest<ForgottenPasswordBloc, ForgottenPasswordState>(
      'initial state is not loading with no error',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.onError, isNull);
      },
    );

    blocTest<ForgottenPasswordBloc, ForgottenPasswordState>(
      'ResetPasswordRequestEventAction calls resetPassword and navigates on success',
      build: () {
        when(mockLoginRepository.resetPassword(any))
            .thenAnswer((_) async => CognitoResetPasswordResult(
                  isPasswordReset: false,
                  nextStep: ResetPasswordStep(updateStep: AuthResetPasswordStep.confirmResetPasswordWithCode),
                ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(ResetPasswordRequestEventAction(
        userName: 'testuser',
        next: () {},
      )),
      expect: () => [
        isA<ForgottenPasswordState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ForgottenPasswordState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', isNull),
      ],
      verify: (bloc) {
        verify(mockLoginRepository.resetPassword('testuser')).called(1);
      },
    );

    blocTest<ForgottenPasswordBloc, ForgottenPasswordState>(
      'ResetPasswordRequestEventAction emits error when reset fails',
      build: () {
        when(mockLoginRepository.resetPassword(any))
            .thenThrow(Exception('User not found'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(ResetPasswordRequestEventAction(
        userName: 'baduser',
        next: () {},
      )),
      expect: () => [
        isA<ForgottenPasswordState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ForgottenPasswordState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', isNotNull),
      ],
    );
  });
}
