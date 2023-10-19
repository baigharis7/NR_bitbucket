import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

bool isEmail(String? string) {
  // Null or empty string is invalid
  if (string.isEmptyOrNull()) {
    return false;
  }

  const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  final regExp = RegExp(pattern);

  if (!regExp.hasMatch(string.orEmpty())) {
    return false;
  }
  return true;
}


FormErrorTypes? validatePasswordOrNull(bool? isLogin,String? password) {
  // if (password == null || password.length < 8 || !_isPasswordValid(password)) {
  if(!isLogin!) {
    if (password == null || password.length < 8 || !_isPasswordValid(password)) {
      return FormErrorTypes.invalidPasswordError;
    } else {
      return null;
    }
  }
  else {
    if (password == null || password.isEmpty) {
      return FormErrorTypes.emptyPasswordError;
    } else {
      return null;
    }
  }
}

bool _isPasswordValid(String password) {
  const pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
  final regExp = RegExp(pattern);

  if (!regExp.hasMatch(password)) {
    return false;
  }
  return true;
}