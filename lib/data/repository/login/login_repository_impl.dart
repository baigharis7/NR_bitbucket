import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/simple_user.dart';
import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/cognito_authentication_service.dart';

class LoginRepositoryImpl extends LoginRepository {

  final CognitoAuthenticationService authenticationService;
  final ProfileApi profileApi;

  LoginRepositoryImpl({required this.authenticationService, required this.profileApi});

  @override
  Future<SignUpResult> signUp(String username, String email, String password) => authenticationService.signUp(username, email, password);

  @override
  Future<SignUpResult> sendVerificationCode(String confirmationCode, String username) => authenticationService.sendVerificationCode(confirmationCode, username);

  @override
  Future<CognitoAuthSession> fetchUserAttributes() async {
    return await authenticationService.fetchUserAttributes();
  }

  @override
  Future<SignInResult> signIn(String username, String password) => authenticationService.signIn(username, password);

  @override
  Future<ResendSignUpCodeResult> resendVerificationCode(String username) => authenticationService.resendVerificationCode(username);

  @override
  Future<void> deleteUser() async => authenticationService.deleteUser();

  @override
  Future<void> saveUserInUsersRemoteDatabase(SimpleUser simpleUser) => profileApi.saveUser(simpleUser);

}