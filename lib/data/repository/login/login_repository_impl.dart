import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_user_credentials_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/cognito_authentication_service.dart';

class LoginRepositoryImpl extends LoginRepository {
  final CognitoAuthenticationService authenticationService;
  final SaveUserCredentialsInteractor saveUserCredentialsInteractor;

  LoginRepositoryImpl({required this.authenticationService, required this.saveUserCredentialsInteractor});

  @override
  Future<SignUpResult> signUp(String username, String email, String password) => authenticationService.signUp(username, email, password);

  @override
  Future<SignUpResult> sendVerificationCode(String confirmationCode, String username) => authenticationService.sendVerificationCode(confirmationCode, username);

  @override
  Future<void> fetchUserAttributes() async {
    try {
      final attributes = await authenticationService.fetchUserAttributes() as CognitoAuthSession;
      saveUserCredentialsInteractor.execute(attributes);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<SignInResult> signIn(String username, String password) => authenticationService.signIn(username, password);

  @override
  Future<ResendSignUpCodeResult> resendVerificationCode(String username) => authenticationService.resendVerificationCode(username);

}