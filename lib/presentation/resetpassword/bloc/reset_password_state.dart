part of 'reset_password_bloc.dart';

// @immutable
// abstract class ResetPasswordState {}

class ResetPasswordState {
  bool isLoading;
  ErrorTypes? onError;

  ResetPasswordState({required this.isLoading, this.onError});

  ResetPasswordState copyWith({required bool isLoading, ErrorTypes? error}) {
    return ResetPasswordState(
      isLoading: isLoading,
      onError: error,
    );
  }
}
