import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';

import 'fetch_user_attributes_interactor.dart';

class FetchUserAttributesInteractorImpl extends FetchUserAttributesInteractor {
  final AuthenticationService authenticationService;

  FetchUserAttributesInteractorImpl({required this.authenticationService});

  @override
  Future<CognitoAuthSession> execute() => authenticationService.fetchUserAttributes();
}