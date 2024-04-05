import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../domain/repository/login/login_repository.dart';

part 'reset_password_event.dart';

part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final LoginRepository loginRepository;
  ResetPasswordBloc({required this.loginRepository}) : super(ResetPasswordState(isLoading: false, isPasswordVisible: false, isRepeatPasswordVisible: false)) {
    on<InitializeEventAction>((event, emit) {
      // TODO: implement event handler
    });

    on<ConfirmResetPasswordEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final result = await loginRepository.confirmResetPassword(event.username, event.password, event.confirmationCode);
        if(!result.isNull()) {
          emit(state.copyWith(isLoading: false, error: null));
        }
        event.onFinish.call();
      } catch(error) {
        emit(state.copyWith(isLoading: false, error: error));
      }
    },);

    on<ChangePasswordVisibilityEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.isPasswordVisible = state.isPasswordVisible! ? false : true;

      emit(state.copyWith(isLoading: false));
    },);

    on<ChangeRepeatPasswordVisibilityEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.isRepeatPasswordVisible = state.isRepeatPasswordVisible! ? false : true;

      emit(state.copyWith(isLoading: false));
    },);
  }
}
