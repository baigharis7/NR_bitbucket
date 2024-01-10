part of 'forgotten_password_bloc.dart';

@immutable
abstract class ForgottenPasswordEvent {}

class InitializeState extends ForgottenPasswordEvent {
  InitializeState();
}

class ResetPasswordRequestEventAction extends ForgottenPasswordEvent {
  final String userName;
  final Function next;

  ResetPasswordRequestEventAction({required this.userName, required this.next});
}
