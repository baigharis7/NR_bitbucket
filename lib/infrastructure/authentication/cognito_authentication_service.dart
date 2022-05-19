import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import 'amplify_service.dart';
import 'authentication_service.dart';

class CognitoAuthenticationService implements AuthenticationService {

  final AmplifyService amplifyService;

  static Future<CognitoAuthenticationService> init({AmplifyService? amplify}) async {
    if (amplify == null) {
      amplify = AmplifyService();
      if (!Amplify.isConfigured) {
        await amplify.addPlugin(AmplifyAuthCognito());
        await amplify.configure(Environment().config!.cognitoConfig.orEmpty());
      }
    }
    return CognitoAuthenticationService._(amplify);
  }

  CognitoAuthenticationService._(this.amplifyService);

  AuthCategory _getAuthorization() {
    return amplifyService.getAuth();
  }

  @override
  Future<SignUpResult> signUp(String username, String email, String password) {
    return _getAuthorization().signUp(
        username: username,
        password: password,
        options: CognitoSignUpOptions(userAttributes: {
          CognitoUserAttributeKey.givenName: username,
          CognitoUserAttributeKey.email: email
        })
    );
  }

  @override
  Future<SignUpResult> sendVerificationCode(
    String confirmationCode,
    String email,
  ) async {
    return _getAuthorization().confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
  }

  @override
  void resendVerificationCode(String username, Function onResendSuccess, Function onResendError) async {
    try {
      await _getAuthorization().resendSignUpCode(username: "Alex1");
      onResendSuccess.call();
    } catch (error) {
      onResendError.call(error);
    }
  }

  @override
  Future<SignInResult> signIn(String username, String password) async {
    return _getAuthorization().signIn(
        username: username,
        password: password
    );
  }

  @override
  Future<AuthSession> fetchUserAttributes() async {
    return await Amplify.Auth.fetchAuthSession(
      options: CognitoSessionOptions(getAWSCredentials: true),
    );
  }

  @override
  Future<SignOutResult> signOut() => _getAuthorization().signOut();

}