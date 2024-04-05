part of 'reset_password_bloc.dart';

// @immutable
// abstract class ResetPasswordState {}

class ResetPasswordState {
  bool isLoading;
  Object? onError;
  bool? isPasswordVisible;
  bool? isRepeatPasswordVisible;

  ResetPasswordState({required this.isLoading, this.onError, this.isPasswordVisible, this.isRepeatPasswordVisible});

  ResetPasswordState copyWith({required bool isLoading, Object? error, bool? isPasswordVisible, bool? isRepeatPasswordVisible}) {
    return ResetPasswordState(
      isLoading: isLoading,
      onError: error,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isRepeatPasswordVisible: isRepeatPasswordVisible ?? this.isRepeatPasswordVisible,
    );
  }

}
