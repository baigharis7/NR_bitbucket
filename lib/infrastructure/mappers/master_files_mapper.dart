import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/foods_and_drinks_names_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/nutrients_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/objectives_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/recommendation_groups_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/sports_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/subjective_analysis_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/units_foods_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/units_info_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/nutrients_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/objectives_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/recommendation_groups_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/subjective_analysis_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_foods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_info_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/objectives_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/subjective_analysis_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

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

    case MasterFilesType.sportsInfo:
      return mapToSportsInfoEntity(masterFileResponse as SportsInfoResponse);

    case MasterFilesType.unitsInfo:
      return mapToUnitsInfoEntity(masterFileResponse as UnitsInfoResponse);

    case MasterFilesType.unitsFoods:
      return mapToUnitsFoodsEntity(masterFileResponse as UnitsFoodsResponse);

    case MasterFilesType.subjectiveAnalysis:
      return mapToSubjectiveAnalysisListMaster(masterFileResponse as SubjectiveAnalysisListResponse);
  }
  
}

CookingMethodsEntity mapToCookingMethodsEntity(CookingMethodsResponse cookingMethodsResponse) {
  List<CookingMethodGroupEntity> data = cookingMethodsResponse.data.map((item) => CookingMethodGroupEntity(g: item.g, m: item.m)).toList();
  return CookingMethodsEntity(id: MasterFilesType.cookingMethods.index, v: cookingMethodsResponse.v, data: data);
}

CookingMethodsMaster mapToCookingMethodsMaster(CookingMethodsEntity cookingMethodsEntity) {
  List<CookingMethod> cookingMethods = cookingMethodsEntity.data.map((item) => CookingMethod(group: item.g, methods: item.m)).toList();
  return CookingMethodsMaster(cookingMethods: cookingMethods);
}

CookingMethodsInfoEntity mapToCookingMethodsInfoEntity(CookingMethodsInfoResponse cookingMethodsInfoResponse) {
  List<CookingMethodInfoEntity> data = cookingMethodsInfoResponse.data.map((item) => CookingMethodInfoEntity(id: item.id, en: item.en, es: item.es)).toList();
  return CookingMethodsInfoEntity(id: MasterFilesType.cookingMethodsInfo.index, v: cookingMethodsInfoResponse.v, data: data);
}

CookingMethodsInfoMaster mapToCookingMethodsInfoMaster(CookingMethodsInfoEntity cookingMethodsInfoEntity) {
  List<CookingMethodInfo> cookingMethodsInfo = cookingMethodsInfoEntity.data.map((item) => CookingMethodInfo(id: item.id, en: item.en, es: item.es)).toList();
  return CookingMethodsInfoMaster(cookingMethodsInfo: cookingMethodsInfo);
}

FoodsAndDrinksNamesEntity mapToFoodsAndDrinksNamesEntity(FoodsAndDrinksNamesResponse foodsAndDrinksNamesResponse) {
  List<FoodItemEntity> foodsNames = foodsAndDrinksNamesResponse.data.foodNames.map((item) => FoodItemEntity(id: item.id, en: item.en, es: item.es, g: item.g, units: item.units)).toList();
  List<FoodItemEntity> drinksNames = foodsAndDrinksNamesResponse.data.drinkNames.map((item) => FoodItemEntity(id: item.id, en: item.en, es: item.es, g: item.g, units: item.units)).toList();
  FoodsAndDrinkListsEntity data = FoodsAndDrinkListsEntity(foodNames: foodsNames, drinkNames: drinksNames);
  return FoodsAndDrinksNamesEntity(id: MasterFilesType.foodsAndDrinksNames.index, v: foodsAndDrinksNamesResponse.v, data: data);
}

FoodsAndDrinksNamesMaster mapToFoodsAndDrinksNamesMaster(FoodsAndDrinksNamesEntity foodsAndDrinksNamesEntity) {
  List<FoodItemMaster> foodsNames = foodsAndDrinksNamesEntity.data.foodNames.map((item) => FoodItemMaster(id: item.id, en: item.en, es: item.es, group: item.g, units: item.units)).toList();
  List<FoodItemMaster> drinksNames = foodsAndDrinksNamesEntity.data.drinkNames.map((item) => FoodItemMaster(id: item.id, en: item.en, es: item.es, group: item.g, units: item.units)).toList();
  FoodsAndDrinkListsMaster foodsAndDrinkListsMaster = FoodsAndDrinkListsMaster(foodNames: foodsNames, drinkNames: drinksNames);
  return FoodsAndDrinksNamesMaster(foodsAndDrinkListsMaster);
}

NutrientsInfoEntity mapToNutrientsInfoEntity(NutrientsInfoResponse nutrientsInfoResponse) {
  List<NutrientInfoEntity> data = nutrientsInfoResponse.data.map((item) => NutrientInfoEntity(name: item.officialName, unit: item.unit, es: item.name_es, en: item.name_en)).toList();
  return NutrientsInfoEntity(id: MasterFilesType.nutrientsInfo.index, v: nutrientsInfoResponse.v, data: data);
}

NutrientsInfoMaster mapToNutrientsInfoMaster(NutrientsInfoEntity nutrientsInfoEntity) {
  List<NutrientInfoMaster> nutrientsInfo = nutrientsInfoEntity.data.map((item) => NutrientInfoMaster(officialName: item.name, unit: item.unit, es: item.es, en: item.en)).toList();
  return NutrientsInfoMaster(nutrientsInfo: nutrientsInfo);
}

ObjectivesInfoEntity mapToObjectivesInfoEntity(ObjectivesInfoResponse objectivesInfoResponse) {
  List<ObjectiveInfoEntity> data = objectivesInfoResponse.data.map((item) => ObjectiveInfoEntity(id: item.id, en: item.en, es: item.es)).toList();
  return ObjectivesInfoEntity(id: MasterFilesType.objectivesInfo.index, v: objectivesInfoResponse.v, data: data);
}

ObjectivesInfoMaster mapToObjectivesInfoMaster(ObjectivesInfoEntity objectivesInfoEntity) {
  List<ObjectiveInfoMaster> objectives = objectivesInfoEntity.data.map((item) => ObjectiveInfoMaster(id: item.id, en: item.en, es: item.es)).toList();
  return ObjectivesInfoMaster(objectives: objectives);
}

RecommendationGroupsEntity mapToRecommendationGroupsEntity(RecommendationGroupsResponse recommendationGroupsResponse) {
  List<RecommendationGroupEntity> data = recommendationGroupsResponse.data.map((item) => RecommendationGroupEntity(id: item.id, groups: item.groups, size: item.size, en: item.en, es: item.es)).toList();
  return RecommendationGroupsEntity(id: MasterFilesType.recommendationGroups.index, v: recommendationGroupsResponse.v, data: data);
}

RecommendationGroupsMaster mapToRecommendationGroupsMaster(RecommendationGroupsEntity recommendationGroupsEntity) {
  List<RecommendationGroup> recommendationGroups = recommendationGroupsEntity.data.map((item) => RecommendationGroup(id: item.id, groups: item.groups, size: item.size, en: item.en, es: item.es)).toList();
  return RecommendationGroupsMaster(recommendationGroups: recommendationGroups);
}

SportsInfoEntity mapToSportsInfoEntity(SportsInfoResponse sportsInfoResponse) {
  List<SportInfoEntity> data = sportsInfoResponse.data.map((item) => SportInfoEntity(id: item.id, en: item.en, es: item.es, mets: item.mets)).toList();
  return SportsInfoEntity(id: MasterFilesType.sportsInfo.index, v: sportsInfoResponse.v, data: data);
}

SportsInfoMaster mapToSportsInfoMaster(SportsInfoEntity sportsInfoEntity) {
  List<SportInfoMaster> sportsInfoMaster = sportsInfoEntity.data.map((item) => SportInfoMaster(id: item.id, en: item.en, es: item.es, mets: item.mets)).toList();
  return SportsInfoMaster(sportsInfoMaster: sportsInfoMaster);
}

UnitsInfoEntity mapToUnitsInfoEntity(UnitsInfoResponse unitsInfoResponse) {
  List<UnitInfoEntity> data = unitsInfoResponse.data.map((item) => UnitInfoEntity(id: item.id, en: item.en, es: item.es)).toList();
  return UnitsInfoEntity(id: MasterFilesType.unitsInfo.index, v: unitsInfoResponse.v, data: data);
}

UnitsInfoMaster mapToUnitsInfoMaster(UnitsInfoEntity unitsInfoEntity) {
  List<UnitInfoMaster> unitsInfoMaster = unitsInfoEntity.data.map((item) => UnitInfoMaster(id: item.id, en: item.en, es: item.es)).toList();
  unitsInfoMaster.add(UnitInfoMaster(id: -1, en: 'grams', es: 'gramos'));
  return UnitsInfoMaster(unitsInfoMaster: unitsInfoMaster);
}

UnitsFoodsEntity mapToUnitsFoodsEntity(UnitsFoodsResponse unitsFoodsResponse) {
  List<UnitFoodEntity> data = unitsFoodsResponse.data.map((item) => UnitFoodEntity(id: item.id, units: item.units)).toList();
  return UnitsFoodsEntity(id: MasterFilesType.unitsFoods.index, v: unitsFoodsResponse.v, data: data);
}

UnitsFoodsMaster mapToUnitsFoodsMaster(UnitsFoodsEntity unitsFoodsEntity) {
  List<UnitFoodMaster> unitsFoodsMaster = unitsFoodsEntity.data.map((item) => UnitFoodMaster(id: item.id, units: item.units)).toList();
  return UnitsFoodsMaster(unitsFoodsMaster: unitsFoodsMaster);
}

SubjectiveAnalysisListMaster mapToSubjectiveAnalysisMaster(SubjectiveAnalysisListEntity subjectiveAnalysisListEntity) {
  final List<SubjectiveAnalysisMaster> subjectiveAnalysisList = subjectiveAnalysisListEntity.data
      .map((entity) => SubjectiveAnalysisMaster(
      questionId: entity.questionId,
      questionType: entity.questionType == 0 ? QuestionType.parameter : QuestionType.test,
      parameter_en: entity.parameter_en,
      parameter_es: entity.parameter_es,
      objectivesId: entity.objectivesId,
      subjectiveAnalysisTestMaster_en: _mapToSubjectiveAnalysisTestMaster(entity.subjectiveAnalysisTestEntity_en),
      subjectiveAnalysisTestMaster_es: _mapToSubjectiveAnalysisTestMaster(entity.subjectiveAnalysisTestEntity_es),
      evaluation: entity.evaluation.orEmpty(),
  ),).toList();

  return SubjectiveAnalysisListMaster(subjectiveAnalysisList: subjectiveAnalysisList);
}

SubjectiveAnalysisTestMaster? _mapToSubjectiveAnalysisTestMaster(SubjectiveAnalysisTestEntity? subjectiveAnalysisTestEntity) {
  if (subjectiveAnalysisTestEntity == null) {
    return null;
  } else {
    return SubjectiveAnalysisTestMaster(
      questions: _mapToTestQuestionMaster(subjectiveAnalysisTestEntity.questions),
    );
  }
}

List<TestQuestionMaster> _mapToTestQuestionMaster(List<TestQuestionEntity> testQuestionEntity) {
  return testQuestionEntity.map((entity) => TestQuestionMaster(
    id: entity.id,
    title: entity.title,
    afirm: entity.afirm,
    neg: entity.neg,
  ),).toList();
}

SubjectiveAnalysisListMaster mapToSubjectiveAnalysisListMaster(SubjectiveAnalysisListResponse response) {
  return SubjectiveAnalysisListMaster(subjectiveAnalysisList: response.data.map((subjectiveAnalysis) => SubjectiveAnalysisMaster(
    questionId: subjectiveAnalysis.q_id,
    questionType: subjectiveAnalysis.q_type == 0 ? QuestionType.parameter : QuestionType.test,
    objectivesId: subjectiveAnalysis.obj_id,
    parameter_en: subjectiveAnalysis.q_en,
    parameter_es: subjectiveAnalysis.q_es,
    // TODO: descomentar cuando tengamos los recursos traducidos
    // subjectiveAnalysisTestMaster_en: SubjectiveAnalysisTestMaster(
    //   testTitle: subjectiveAnalysis.ans_en!.testTitle,
    //   questions: mapToTestQuestionMasterList(subjectiveAnalysis.ans_en!.questions),
    // ),
    subjectiveAnalysisTestMaster_en: null,
    subjectiveAnalysisTestMaster_es: SubjectiveAnalysisTestMaster(
      questions: mapToTestQuestionMasterList(subjectiveAnalysis.ans_es!),
    ),
    evaluation: subjectiveAnalysis.eval.orEmpty(),
  ),).toList(),);
}

List<TestQuestionMaster> mapToTestQuestionMasterList(List<TestQuestionAnswerResponse> questions) {
  final masterQuestions = <TestQuestionMaster>[];
  for (var question in questions) {
    final testQuestion = TestQuestionMaster(id: question.id, title: question.title, afirm: question.afirm, neg: question.neg);
    masterQuestions.add(testQuestion);
  }
  return masterQuestions;
}