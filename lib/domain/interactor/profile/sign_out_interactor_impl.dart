import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/sign_out_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';

class SignOutInteractorImpl extends SignOutInteractor {
  final AuthenticationService authenticationService;

  SignOutInteractorImpl({required this.authenticationService});

  @override
  Future<SignOutResult> execute() => authenticationService.signOut();

}