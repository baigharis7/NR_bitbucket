import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_user_credentials_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';

class SaveUserCredentialsInteractorImpl extends SaveUserCredentialsInteractor {
  final PreferencesRepository preferencesRepository;

  SaveUserCredentialsInteractorImpl({required this.preferencesRepository});

  @override
  Future<void> execute(CognitoAuthSession session) async {
    preferencesRepository.setUserCredentials(session);
  }

}