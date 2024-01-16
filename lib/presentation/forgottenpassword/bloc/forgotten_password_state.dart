part of 'forgotten_password_bloc.dart';

// @immutable
// abstract class ForgottenPasswordState {}

class ForgottenPasswordState {
  bool isLoading;
  ErrorTypes? onError;

  ForgottenPasswordState({required this.isLoading, this.onError});

  ForgottenPasswordState copyWith({required isLoading, ErrorTypes? error}) {
    return ForgottenPasswordState(
      isLoading: isLoading,
      onError: error,
    );
  }
}
