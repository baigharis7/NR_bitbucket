class LoginActions {
  LoginActions();
}

class InitialiseBlocAction extends LoginActions {
  Function goToRegistry;

  InitialiseBlocAction({required this.goToRegistry});
}

class SendVerificationCodeAction extends LoginActions {
  String confirmationCode;
  Function onSuccess;

  SendVerificationCodeAction({required this.confirmationCode, required this.onSuccess});
}

class ResendVerificationCodeAction extends LoginActions {

  ResendVerificationCodeAction();
}

class UnconfirmedUserCancelsConfirmationCodeReceptionAction extends LoginActions {

  UnconfirmedUserCancelsConfirmationCodeReceptionAction();
}

class UnconfirmedUserAsksForNewVerificationCodeAction extends LoginActions {
  Function? showMfaDialog;

  UnconfirmedUserAsksForNewVerificationCodeAction({required this.showMfaDialog});
}

class LaunchLoginAction extends LoginActions {
  String? username;
  String? password;
  String? confirmPassword;
  String? repeatPassword;
  String? email;
  Function? action;

  LaunchLoginAction({
    this.username,
    this.password,
    this.confirmPassword,
    this.repeatPassword,
    this.email,
    this.action,
  });
}

class ChangePasswordVisibilityAction extends LoginActions {
  ChangePasswordVisibilityAction();
}

class ChangeLoginModeAction extends LoginActions {
  Function action;

  ChangeLoginModeAction({required this.action});
}

