import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

class RecommendationsApi extends ApiHelper {
  RecommendationsApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService) : super(preferencesRepository, authenticationService);

  Future<Map<String, dynamic>> getRecommendation(String userId) =>
      get(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/recommendations',
          {Constants.USERID_QUERY: userId.toString()},
        ),
      );

}