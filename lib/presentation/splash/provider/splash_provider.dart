import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/num_constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/token_utils.dart';

class SplashProvider extends ChangeNotifier {
  final GetIdTokenInteractor getIdTokenInteractor;

  SplashProvider({required this.getIdTokenInteractor});

  void init({required Function toLogin, required Function toDashboard}) {
    nextScreen(toLogin, toDashboard);
  }

  void nextScreen(Function toLogin, Function toDashboard) {
    Future.delayed(
      const Duration(seconds: NumConstants.splashDelay),
        () => doAccordingToToken(toLogin, toDashboard)
    );
  }

  void doAccordingToToken(Function toLogin, Function toDashboard) async {
    final tokenId = getIdTokenInteractor.execute();
    if (tokenId == '' || isTokenExpired(tokenId)) {
      toLogin.call();
    } else {
      toDashboard.call();
    }
  }

}