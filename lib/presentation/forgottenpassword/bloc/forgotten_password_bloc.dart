import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/repository/login/login_repository.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'forgotten_password_event.dart';

part 'forgotten_password_state.dart';

class ForgottenPasswordBloc
    extends Bloc<ForgottenPasswordEvent, ForgottenPasswordState> {
  final LoginRepository loginRepository;
  ForgottenPasswordBloc({required this.loginRepository})
      : super(
          ForgottenPasswordState(
            isLoading: false,
          ),
        ) {
    on<InitializeState>((event, emit) {
      // TODO: implement event handler
    });

    on<ResetPasswordRequestEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        final result = await loginRepository.resetPassword(event.userName);
        event.next.call();
        emit(state.copyWith(isLoading: false, error: null));
      } catch (error) {
          emit(state.copyWith(isLoading: false, error: error));
      }

      // emit(state.copyWith(isLoading: false));
    },);
  }
}
