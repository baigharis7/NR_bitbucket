import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/simple_user.dart';
import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/cognito_authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

class LoginRepositoryImpl extends LoginRepository {

  final CognitoAuthenticationService authenticationService;
  final ProfileApi profileApi;
  final SyncQueueService syncQueue;

  LoginRepositoryImpl({required this.authenticationService, required this.profileApi, required this.syncQueue});

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
  Future<void> saveUserInUsersRemoteDatabase(SimpleUser simpleUser) {
    // Fire-and-forget: don't block signup flow on network call
    profileApi.saveUser(simpleUser).catchError((error) {
      syncQueue.enqueue('/users', simpleUser);
      return <String, dynamic>{};
    });
    return Future.value();
  }

  @override
  Future<ResetPasswordResult> resetPassword(String username) => authenticationService.resetPassword(username);

  @override
  Future<UpdatePasswordResult> confirmResetPassword(String username, String newPassword, String confirmationCode) => authenticationService.confirmResetPassword(username, newPassword, confirmationCode);

}