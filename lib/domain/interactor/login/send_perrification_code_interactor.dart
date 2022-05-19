import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

abstract class SendVerificationCodeInteractor {
  Future<SignUpResult> execute(String confirmationCode, String username);
}