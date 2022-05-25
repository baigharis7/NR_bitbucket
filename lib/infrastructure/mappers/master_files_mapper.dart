import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/foods_and_drinks_names_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/nutrients_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/objectives_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/recommendation_groups_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/nutrients_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/objectives_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/recommendation_groups_entity.dart';

dynamic mapToMasterFileEntity(dynamic masterFileResponse, MasterFilesType masterFilesType) {
  switch (masterFilesType) {

    case MasterFilesType.cookingMethods:
      return mapToCookingMethodsEntity(masterFileResponse as CookingMethodsResponse);

    case MasterFilesType.cookingMethodsInfo:
      return mapToCookingMethodsInfoEntity(masterFileResponse as CookingMethodsInfoResponse);

    case MasterFilesType.foodsAndDrinksNames:
      return mapToFoodsAndDrinksNamesEntity(masterFileResponse as FoodsAndDrinksNamesResponse);

    case MasterFilesType.nutrientsInfo:
      return mapToNutrientsInfoEntity(masterFileResponse as NutrientsInfoResponse);

    case MasterFilesType.objectivesInfo:
      return mapToObjectivesInfoEntity(masterFileResponse as ObjectivesInfoResponse);

    case MasterFilesType.recommendationGroups:
      return mapToRecommendationGroupsEntity(masterFileResponse as RecommendationGroupsResponse);

  }
}

CookingMethodsEntity mapToCookingMethodsEntity(CookingMethodsResponse cookingMethodsResponse) {
  List<CookingMethodGroupEntity> data = cookingMethodsResponse.data.map((item) => CookingMethodGroupEntity(g: item.g, m: item.m)).toList();
  return CookingMethodsEntity(id: MasterFilesType.cookingMethods.index, v: cookingMethodsResponse.v, data: data);
}

CookingMethodsInfoEntity mapToCookingMethodsInfoEntity(CookingMethodsInfoResponse cookingMethodsInfoResponse) {
  List<CookingMethodInfoEntity> data = cookingMethodsInfoResponse.data.map((item) => CookingMethodInfoEntity(id: item.id, en: item.en, es: item.es)).toList();
  return CookingMethodsInfoEntity(id: MasterFilesType.cookingMethodsInfo.index, v: cookingMethodsInfoResponse.v, data: data);
}

FoodsAndDrinksNamesEntity mapToFoodsAndDrinksNamesEntity(FoodsAndDrinksNamesResponse foodsAndDrinksNamesResponse) {
  List<FoodItemEntity> foodsNames = foodsAndDrinksNamesResponse.data.foodNames.map((item) => FoodItemEntity(id: item.id, en: item.en, es: item.es, g: item.g)).toList();
  List<FoodItemEntity> drinksNames = foodsAndDrinksNamesResponse.data.drinkNames.map((item) => FoodItemEntity(id: item.id, en: item.en, es: item.es, g: item.g)).toList();
  FoodsAndDrinkListsEntity data = FoodsAndDrinkListsEntity(foodNames: foodsNames, drinkNames: drinksNames);
  return FoodsAndDrinksNamesEntity(id: MasterFilesType.foodsAndDrinksNames.index, v: foodsAndDrinksNamesResponse.v, data: data);
}

NutrientsInfoEntity mapToNutrientsInfoEntity(NutrientsInfoResponse nutrientsInfoResponse) {
  List<NutrientInfoEntity> data = nutrientsInfoResponse.data.map((item) => NutrientInfoEntity(name: item.name, unit: item.unit, es: item.es, en: item.en)).toList();
  return NutrientsInfoEntity(id: MasterFilesType.nutrientsInfo.index, v: nutrientsInfoResponse.v, data: data);
}

ObjectivesInfoEntity mapToObjectivesInfoEntity(ObjectivesInfoResponse objectivesInfoResponse) {
  List<ObjectiveInfoEntity> data = objectivesInfoResponse.data.map((item) => ObjectiveInfoEntity(id: item.id, en: item.en, es: item.es)).toList();
  return ObjectivesInfoEntity(id: MasterFilesType.objectivesInfo.index, v: objectivesInfoResponse.v, data: data);
}

RecommendationGroupsEntity mapToRecommendationGroupsEntity(RecommendationGroupsResponse recommendationGroupsResponse) {
  List<RecommendationGroupEntity> data = recommendationGroupsResponse.data.map((item) => RecommendationGroupEntity(id: item.id, groups: item.groups, size: item.size, en: item.en, es: item.es)).toList();
  return RecommendationGroupsEntity(id: MasterFilesType.recommendationGroups.index, v: recommendationGroupsResponse.v, data: data);
}

