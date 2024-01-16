part of 'reset_password_bloc.dart';

@immutable
abstract class ResetPasswordEvent {}

class InitializeEventAction extends ResetPasswordEvent {}

class ConfirmResetPasswordEventAction extends ResetPasswordEvent {
  final String username;
  final String password;
  final String confirmationCode;
  final Function onFinish;

  ConfirmResetPasswordEventAction(
      {required this.username,
      required this.password,
      required this.confirmationCode,
      required this.onFinish,});
}

class ChangePasswordVisibilityEventAction extends ResetPasswordEvent {}

class ChangeRepeatPasswordVisibilityEventAction extends ResetPasswordEvent {}