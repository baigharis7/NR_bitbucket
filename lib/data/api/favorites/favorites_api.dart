import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/data/api/favorites/model/food/upload_food_favorite.dart';
import 'package:nutrenaissance_flutter/data/api/favorites/model/liquid/upload_liquid_favorite.dart';
import 'package:nutrenaissance_flutter/data/api/favorites/model/sport/upload_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class FavoritesApi extends ApiHelper {

  FavoritesApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> uploadFoodFavorite(UploadFoodFavorite uploadFoodFavorite) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/favorites/food',
        ),
        uploadFoodFavorite,
      );

  Future<Map<String, dynamic>> deleteFoodFavorite(String userId, int eventDate) =>
      delete(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/favorites/food',
        ),
        {
          'userId': userId,
          'eventDate': eventDate
        },
      );

  Future<Map<String, dynamic>> uploadSportFavorite(UploadSportFavorite uploadSportFavorite) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/favorites/sport',
        ),
        uploadSportFavorite,
      );

  Future<Map<String, dynamic>> deleteSportFavorite(String userId, int eventDate) =>
      delete(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/favorites/sport',
        ),
        {
          'userId': userId,
          'eventDate': eventDate
        },
      );

  Future<Map<String, dynamic>> uploadLiquidFavorite(UploadLiquidFavorite uploadLiquidFavorite) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/favorites/liquid',
        ),
        uploadLiquidFavorite,
      );

  Future<Map<String, dynamic>> deleteLiquidFavorite(String userId, int eventDate) =>
      delete(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/favorites/liquid',
        ),
        {
          'userId': userId,
          'eventDate': eventDate
        },
      );
}