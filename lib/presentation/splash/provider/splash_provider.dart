import 'package:chuck_interceptor/chuck.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/num_constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/token_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/api/profile/profile_api.dart';
import '../../../data/repository/localstorage/local_storage_impl.dart';
import '../../../data/repository/profile/profile_repository_impl.dart';
import '../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../domain/interactor/profile/get_profile_interactor_impl.dart';
import '../../../domain/repository/localstorage/local_storage.dart';
import '../../../domain/repository/preferences/preferences.dart';
import '../../../domain/repository/preferences/preferences_repository.dart';
import '../../../domain/repository/profile/profile_repository.dart';
import '../../../infrastructure/authentication/cognito_authentication_service.dart';

class SplashProvider extends ChangeNotifier {
  GetIdTokenInteractor? getIdTokenInteractor;
  late GetProfileInteractor getProfileInteractor;
  late ProfileRepository profileRepository;
  late LocalStorageRepository localStorageRepository;
  late ProfileApi profileApi;
  String? idToken;

  SplashProvider();

  void init({required Function toLogin, required Function toDashboard}) async {
    final authenticationService = await CognitoAuthenticationService.init();
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Chuck chuck = Chuck(
      showNotification: true,
      showInspectorOnShake: true,
      darkTheme: false,
      maxCallsCount: 1000,
    );

    final Preferences prefs = PreferencesImpl(sharedPreferences);
    final PreferencesRepository prefsRepository = PreferencesRepositoryImpl(prefs: prefs);
    profileApi = ProfileApi(prefsRepository, authenticationService, chuck);
    localStorageRepository = LocalStorageImpl();
    profileRepository = ProfileRepositoryImpl(profileApi: profileApi, localStorageRepository: localStorageRepository);
    getProfileInteractor = GetProfileInteractorImpl(profileRepository: profileRepository);

    final profile = await getProfileInteractor.execute();
    getIdTokenInteractor = GetIdTokenInteractorImpl(
        preferencesRepository: PreferencesRepositoryImpl(
            prefs: PreferencesImpl(
                await SharedPreferences.getInstance(),
            ),
        ),
    );
    idToken = getIdTokenInteractor!.execute();
    nextScreen(toLogin, toDashboard, profile);
  }

  void nextScreen(Function toLogin, Function toDashboard, UserProfileModel? profile) async {

    Future.delayed(
        const Duration(seconds: NumConstants.splashDelay),
            () async => await doAccordingToToken(toLogin, toDashboard, profile),
    );
  }

  Future<void> doAccordingToToken(Function toLogin, Function toDashboard, UserProfileModel? profile) async {
    if (/*idToken == '' || isTokenExpired(idToken.orEmpty())  || */profile.isNull() || (profile!.objectives.orEmpty().isEmpty && profile.physicalCharacteristics.isNull())) {
      toLogin.call();
    } else {
      toDashboard.call();
    }
  }

}