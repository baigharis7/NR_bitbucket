import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

abstract class SaveUserCredentialsInteractor {
  void execute(CognitoAuthSession session);
}