part of 'reset_password_bloc.dart';

// @immutable
// abstract class ResetPasswordState {}

class ResetPasswordState {
  bool isLoading;
  ErrorTypes? onError;
  bool? isPasswordVisible;

  ResetPasswordState({required this.isLoading, this.onError, this.isPasswordVisible});

  ResetPasswordState copyWith({required bool isLoading, ErrorTypes? error, bool? isPasswordVisible}) {
    return ResetPasswordState(
      isLoading: isLoading,
      onError: error,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }

}
