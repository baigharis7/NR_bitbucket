import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

abstract class AuthenticationService {
  Future<SignUpResult> signUp(String username, String email, String password);
  Future<SignUpResult> sendVerificationCode(String email, String confirmationCode);
  void resendVerificationCode(String username, Function onResendSuccess, Function onResendError);
  Future<SignInResult> signIn(String username, String password);
  Future<AuthSession> fetchUserAttributes();
  Future<SignOutResult> signOut();
}