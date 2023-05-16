import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/amplify_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

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

  AuthCategory getAuthorization() {
    return amplifyService.getAuth();
  }

  @override
  Future<SignUpResult> signUp(String username, String email, String password) {

    return getAuthorization().signUp(
        username: username,
        password: password,
        options: CognitoSignUpOptions(userAttributes: {
          CognitoUserAttributeKey.givenName: username,
          CognitoUserAttributeKey.email: email,
        },),
    );
  }

  @override
  Future<SignUpResult> sendVerificationCode(
    String confirmationCode,
    String email,
  ) async {
    return getAuthorization().confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
  }

  @override
  Future<ResendSignUpCodeResult> resendVerificationCode(String username) async {
      return await getAuthorization().resendSignUpCode(username: username);
  }

  @override
  Future<SignInResult> signIn(String username, String password) async {
    return getAuthorization().signIn(
        username: username,
        password: password,
    );
  }

  @override
  Future<CognitoAuthSession> fetchUserAttributes() async {

    final authSession = await getAuthorization().fetchAuthSession(
      options: CognitoSessionOptions(getAWSCredentials: true),
    );
    return authSession as CognitoAuthSession;
  }

  @override
  Future<SignOutResult> signOut() => getAuthorization().signOut();

  Future<void> deleteUser() async {
    await getAuthorization().deleteUser();
  }

}