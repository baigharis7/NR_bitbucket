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
  if(isLogin!) {
    return null;
  }
  if (password == null || password.isEmpty) {
    return FormErrorTypes.emptyPasswordError;
  }
  if (password.length < 8 || !_isPasswordValid(password)) {
    return FormErrorTypes.invalidPasswordError;
  }
  return null;
}

bool _isPasswordValid(String password) {
  const pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};:,.<>?/\\|`~"' "'" r'])[A-Za-z\d!@#$%^&*()_+\-=\[\]{};:,.<>?/\\|`~"' "'" r']{8,}$';
  final regExp = RegExp(pattern);

  if (!regExp.hasMatch(password)) {
    return false;
  }
  return true;
}