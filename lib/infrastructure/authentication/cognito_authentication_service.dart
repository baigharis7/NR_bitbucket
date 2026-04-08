import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/amplify_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

class CognitoAuthenticationService implements AuthenticationService {
  CognitoAuthenticationService._();
  static final CognitoAuthenticationService instance = CognitoAuthenticationService._();

  AmplifyService? _amplifyService;
  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initialize Amplify/Cognito. Safe to call multiple times — only the first
  /// call does work. Returns this instance for convenience.
  Future<CognitoAuthenticationService> initialize() async {
    if (_initialized) return this;
    _amplifyService = AmplifyService();
    if (!Amplify.isConfigured) {
      await _amplifyService!.addPlugin(AmplifyAuthCognito());
      await _amplifyService!.configure(Environment().config!.cognitoConfig.orEmpty());
    }
    _initialized = true;
    return this;
  }

  AuthCategory getAuthorization() {
    return _amplifyService!.getAuth();
  }

  @override
  Future<SignUpResult> signUp(String username, String email, String password) {

    return getAuthorization().signUp(
        username: username,
        password: password,
        options: SignUpOptions(userAttributes: {
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
      options: const FetchAuthSessionOptions(forceRefresh: true),
    );
    return authSession as CognitoAuthSession;
  }

  @override
  Future<SignOutResult> signOut() => getAuthorization().signOut();

  Future<void> deleteUser() async {
    await getAuthorization().deleteUser();
  }

  @override
  Future<ResetPasswordResult> resetPassword(String username) async {
    return await getAuthorization().resetPassword(username: username);
  }

  @override
  Future<ResetPasswordResult> confirmResetPassword(String username, String newPassword, String confirmationCode) async {
    return await getAuthorization().confirmResetPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode);
  }

}
