import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

abstract class LoginRepository {
  Future<SignUpResult> signUp(String username, String email, String password);
  Future<SignUpResult> sendVerificationCode(String confirmationCode, String username);
  Future<void> fetchUserAttributes();
  Future<SignInResult> signIn(String username, String password);
}