import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

abstract class SignInInteractor {
  Future<SignInResult> execute(String username, String password);
}