import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class RecipesApi extends ApiHelper {
  RecipesApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService) : super(preferencesRepository, authenticationService);

  Future<Map<String, dynamic>> getRecipe(List<int> foodIds, List<int> exclusions) =>
      get(
          Uri.https(
              Environment().config!.baseUrl,
              '${Environment().config!.distributionPath}/recipes',
              {
                'foodIds' : foodIds.join(','),
                'exclusions' : exclusions.join(','),
              }
          ),
      );
}