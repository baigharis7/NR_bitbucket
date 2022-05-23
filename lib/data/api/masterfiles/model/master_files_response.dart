import 'package:nutrenaissance_flutter/data/api/masterfiles/model/foods_and_drinks_names_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/nutrients_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/objectives_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/recommendation_groups_response.dart';

class MasterFilesResponse {
  CookingMethodsResponse? cookingMethodsResponse;
  NutrientsInfoResponse? nutrientsInfoResponse;
  FoodsAndDrinksNamesResponse? foodsAndDrinksNamesResponse;
  ObjectivesInfoResponse? objectivesResponse;
  RecommendationGroupsResponse? recommendationGroupsResponse;

  MasterFilesResponse(
      {
        required this.cookingMethodsResponse,
        required this.nutrientsInfoResponse,
        required this.foodsAndDrinksNamesResponse,
        required this.objectivesResponse,
        required this.recommendationGroupsResponse,
      }
  );
}