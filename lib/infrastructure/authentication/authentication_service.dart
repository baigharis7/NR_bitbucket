import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

abstract class AuthenticationService {
  Future<SignUpResult> signUp(String username, String email, String password);
  Future<SignUpResult> sendVerificationCode(String email, String confirmationCode);
  Future<ResendSignUpCodeResult> resendVerificationCode(String username);
  Future<SignInResult> signIn(String username, String password);
  Future<CognitoAuthSession> fetchUserAttributes();
  Future<SignOutResult> signOut();
}