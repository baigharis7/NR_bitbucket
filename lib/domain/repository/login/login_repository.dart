import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/simple_user.dart';

abstract class LoginRepository {
  Future<SignUpResult> signUp(String username, String email, String password);
  Future<SignUpResult> sendVerificationCode(String confirmationCode, String username);
  Future<CognitoAuthSession> fetchUserAttributes();
  Future<SignInResult> signIn(String username, String password);
  Future<ResendSignUpCodeResult> resendVerificationCode(String username);
  Future<void> deleteUser();
  Future<void> saveUserInUsersRemoteDatabase(SimpleUser simpleUser);
  Future<ResetPasswordResult> resetPassword(String username);
  Future<ResetPasswordResult> confirmResetPassword(String username, String newPassword, String confirmationCode);

}