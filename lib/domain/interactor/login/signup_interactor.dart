import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

abstract class SignUpInteractor {
  Future<SignUpResult> execute(String email, String password);
}