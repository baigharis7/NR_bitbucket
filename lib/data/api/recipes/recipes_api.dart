import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

import '../../../domain/models/recipes/upload_recipe_favorite.dart';

class RecipesApi extends ApiHelper {
  RecipesApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

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

  Future<Map<String, dynamic>> uploadRecipeFavorite(UploadRecipeFavorite uploadRecipeFavorite) =>
      post(
          Uri.https(
              Environment().config!.baseUrl,
              '${Environment().config!.distributionPath}/favorites/recipe',
          ),
        uploadRecipeFavorite,
      );

  Future<Map<String, dynamic>> deleteRecipeFavorite(String userId, int eventDate) =>
      delete(
          Uri.https(
              Environment().config!.baseUrl,
              '${Environment().config!.distributionPath}/favorites/recipe',
          ),
        {
          'userId': userId,
          'eventDate': eventDate,
        },
      );
}