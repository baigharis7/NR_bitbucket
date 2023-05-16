import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class LoginState {
  String? username;
  String? password;
  String? email;
  bool isLoading;
  ErrorTypes? errorTypes;
  bool notConfirmedUserTryingToLogin;
  bool isProfileChecked;
  bool areMasterFilesChecked;
  Function? goToRegistry;
  bool isLogin;
  bool isPasswordVisible;
  bool loginFinished;
  bool isFromVerificationCode;

  LoginState({
    this.username,
    this.password,
    this.email,
    this.isLoading = false,
    this.errorTypes,
    this.notConfirmedUserTryingToLogin = false,
    this.isProfileChecked = false,
    this.areMasterFilesChecked = false,
    this.goToRegistry,
    this.isLogin = true,
    this.isPasswordVisible = false,
    this.loginFinished = false,
    this.isFromVerificationCode = false,
  });
}