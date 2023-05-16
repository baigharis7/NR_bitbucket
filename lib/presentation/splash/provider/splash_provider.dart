import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor_impl.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/num_constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/token_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashProvider extends ChangeNotifier {
  GetIdTokenInteractor? getIdTokenInteractor;
  String? idToken;

  SplashProvider();

  void init({required Function toLogin, required Function toDashboard}) async {
    getIdTokenInteractor = GetIdTokenInteractorImpl(
        preferencesRepository: PreferencesRepositoryImpl(
            prefs: PreferencesImpl(
                await SharedPreferences.getInstance(),
            ),
        ),
    );
    idToken = getIdTokenInteractor!.execute();
    nextScreen(toLogin, toDashboard);
  }

  void nextScreen(Function toLogin, Function toDashboard) async {

    Future.delayed(
        const Duration(seconds: NumConstants.splashDelay),
            () async => await doAccordingToToken(toLogin, toDashboard),
    );
  }

  Future<void> doAccordingToToken(Function toLogin, Function toDashboard) async {
    if (idToken == '' || isTokenExpired(idToken.orEmpty())) {
      toLogin.call();
    } else {
      toDashboard.call();
    }
  }

}