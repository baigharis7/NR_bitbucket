import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_oils_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/conversion_factors_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/conversion_factors_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/foods_and_drinks_names_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/nutrients_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/objectives_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/oil_types_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/recommendation_groups_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/sports_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/subjective_analysis_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/supplements_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/units_foods_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/units_info_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/conversion_factors_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/conversion_factors_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_oils_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/nutrients_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/objectives_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/oil_types_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/recommendation_groups_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/subjective_analysis_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/supplements_info_entity.dart';
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
import 'package:nutrenaissance_flutter/domain/models/masterfiles/supplements_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

dynamic mapToMasterFileEntity(dynamic masterFileResponse, MasterFilesType masterFilesType) {
  switch (masterFilesType) {

    case MasterFilesType.cookingMethods:
      return mapToCookingMethodsEntity(masterFileResponse as CookingMethodsResponse);

    case MasterFilesType.cookingMethodsInfo:
      return mapToCookingMethodsInfoEntity(masterFileResponse as CookingMethodsInfoResponse);

    case MasterFilesType.oilTypes:
      return mapToOilTypesEntity(masterFileResponse as OilTypesResponse);

    case MasterFilesType.conversionFactors:
      return mapToConversionFactorsEntity(masterFileResponse as ConversionFactorsResponse);

    case MasterFilesType.conversionFactorsInfo:
      return mapToConversionFactorsInfoEntity(masterFileResponse as ConversionFactorsInfoResponse);

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

    case MasterFilesType.supplementsInfo:
      return mapToSupplementsInfoEntity(masterFileResponse as SupplementsInfoResponse);

    case MasterFilesType.subjectiveAnalysis:
      return mapToSubjectiveAnalysisListMaster(masterFileResponse as SubjectiveAnalysisListResponse);

    case MasterFilesType.cookingMethodsOilsInfo:
      return mapToCookingMethodsOilsInfoEntity(masterFileResponse as CookingMethodsOilsInfoResponse);
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

OilTypesEntity mapToOilTypesEntity(OilTypesResponse oilTypesResponse) {
  List<OilTypeEntity> data = oilTypesResponse.data.map((item) => OilTypeEntity(id: item.id, en: item.en, es: item.es)).toList();
  return OilTypesEntity(id: MasterFilesType.oilTypes.index, v: oilTypesResponse.v, data: data);
}

ConversionFactorsEntity mapToConversionFactorsEntity(ConversionFactorsResponse conversionFactorsResponse) {
  List<ConversionFactorEntity> data = conversionFactorsResponse.data.map((item) => ConversionFactorEntity(id: item.id, en: item.en, es: item.es)).toList();
  return ConversionFactorsEntity(id: MasterFilesType.conversionFactors.index, v: conversionFactorsResponse.v, data: data);
}

ConversionFactorsInfoEntity mapToConversionFactorsInfoEntity(ConversionFactorsInfoResponse conversionFactorsInfoResponse) {
  List<ConversionFactorInfoEntity> data = conversionFactorsInfoResponse.data.map((item) => ConversionFactorInfoEntity(id: item.id, value: item.value, list: item.list.map((e) => ConversionInfoEntity(g: e.g, v: e.v)).toList())).toList();
  return ConversionFactorsInfoEntity(id: MasterFilesType.conversionFactors.index, v: conversionFactorsInfoResponse.v, data: data);
}

CookingMethodsInfoMaster mapToCookingMethodsInfoMaster(CookingMethodsInfoEntity cookingMethodsInfoEntity) {
  List<CookingMethodInfo> cookingMethodsInfo = cookingMethodsInfoEntity.data.map((item) => CookingMethodInfo(id: item.id, en: item.en, es: item.es)).toList();
  return CookingMethodsInfoMaster(cookingMethodsInfo: cookingMethodsInfo);
}

OilTypesResponse mapToOilTypesResponse(OilTypesEntity oilTypesEntity) {
  List<OilTypeResponse> oilTypeResponse = oilTypesEntity.data.map((item) => OilTypeResponse(id: item.id, en: item.en, es: item.es)).toList();
  return OilTypesResponse(v: oilTypesEntity.v, data: oilTypeResponse);
}

ConversionFactorsResponse mapToConversionFactorsResponse(ConversionFactorsEntity conversionFactorsEntity) {
  List<ConversionFactor> conversionFactors = conversionFactorsEntity.data.map((item) => ConversionFactor(id: item.id, en: item.en, es: item.es)).toList();
  return ConversionFactorsResponse(v: conversionFactorsEntity.v, data: conversionFactors);
}

ConversionFactorsInfoResponse mapToConversionFactorsInfoResponse(ConversionFactorsInfoEntity conversionFactorsInfoEntity) {
  List<ConversionFactorInfoResponse> conversionFactorsInfo = conversionFactorsInfoEntity.data.map((item) => ConversionFactorInfoResponse(id: item.id, value: item.value, list: item.list.map((e) => ConversionFactorResponse(g: e.g, v: e.v)).toList())).toList();
  return ConversionFactorsInfoResponse(v: conversionFactorsInfoEntity.v, data: conversionFactorsInfo);
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
  List<NutrientInfoEntity> data = nutrientsInfoResponse.data.map((item) => NutrientInfoEntity(name: item.officialName, unit: item.unit, es: item.name_es, en: item.name_en, description_es: item.description_es, description_en: item.description_en, foods_es: item.foods_es, foods_en: item.foods_en, abbr: item.abbr)).toList();
  return NutrientsInfoEntity(id: MasterFilesType.nutrientsInfo.index, v: nutrientsInfoResponse.v, data: data);
}

NutrientsInfoMaster mapToNutrientsInfoMaster(NutrientsInfoEntity nutrientsInfoEntity) {
  List<NutrientInfoMaster> nutrientsInfo = nutrientsInfoEntity.data.map((item) => NutrientInfoMaster(officialName: item.name, unit: item.unit, es: item.es, en: item.en, description_es: item.description_es, description_en: item.description_en, foods_es: item.foods_es, foods_en: item.foods_en, abbr: item.abbr)).toList();
  return NutrientsInfoMaster(nutrientsInfo: nutrientsInfo);
}

ObjectivesInfoEntity mapToObjectivesInfoEntity(ObjectivesInfoResponse objectivesInfoResponse) {
  List<ObjectiveInfoEntity> data = objectivesInfoResponse.data.map((item) => ObjectiveInfoEntity(id: item.id, en: item.en, es: item.es)).toList();
  List<ObjectiveInfoEntity> metabolicObjectives = objectivesInfoResponse.metabolicObjectives.map((item) => ObjectiveInfoEntity(id: item.id, en: item.en, es: item.es)).toList();
  List<ObjectiveInfoEntity> bodyCompositionObjectives = objectivesInfoResponse.bodyCompositionObjectives.map((item) => ObjectiveInfoEntity(id: item.id, en: item.en, es: item.es)).toList();
  return ObjectivesInfoEntity(id: MasterFilesType.objectivesInfo.index, v: objectivesInfoResponse.v, data: data, metabolicObjectives: metabolicObjectives, bodyCompositionObjectives: bodyCompositionObjectives);
}

ObjectivesInfoMaster mapToObjectivesInfoMaster(ObjectivesInfoEntity objectivesInfoEntity) {
  List<ObjectiveInfoMaster> objectives = objectivesInfoEntity.data.map((item) => ObjectiveInfoMaster(id: item.id, en: item.en, es: item.es)).toList();
  List<ObjectiveInfoMaster> metabolicObjectives = objectivesInfoEntity.metabolicObjectives.map((item) => ObjectiveInfoMaster(id: item.id, en: item.en, es: item.es)).toList();
  List<ObjectiveInfoMaster> bodyCompositionObjectives = objectivesInfoEntity.bodyCompositionObjectives.map((item) => ObjectiveInfoMaster(id: item.id, en: item.en, es: item.es)).toList();
  return ObjectivesInfoMaster(objectives: objectives, metabolicObjectives: metabolicObjectives, bodyCompositionObjectives: bodyCompositionObjectives);
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
  List<UnitInfoEntity> data = unitsInfoResponse.data.map((item) => UnitInfoEntity(id: item.id, en: item.en, es: item.es, enPlural: item.enPlural, esPlural: item.esPlural)).toList();
  return UnitsInfoEntity(id: MasterFilesType.unitsInfo.index, v: unitsInfoResponse.v, data: data);
}

UnitsInfoMaster mapToUnitsInfoMaster(UnitsInfoEntity unitsInfoEntity) {
  List<UnitInfoMaster> unitsInfoMaster = unitsInfoEntity.data.map((item) => UnitInfoMaster(id: item.id, en: item.en, es: item.es, enPlural: item.enPlural, esPlural: item.esPlural)).toList();
  unitsInfoMaster.add(UnitInfoMaster(id: -1, en: 'select', es: 'seleccionar'));
  unitsInfoMaster.add(UnitInfoMaster(id: -2, en: 'gram', es: 'gramo', enPlural: 'grams', esPlural: 'gramos'));
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

SupplementsInfoEntity mapToSupplementsInfoEntity(SupplementsInfoResponse supplementsInfoResponse) {
  List<SupplementInfoEntity> data = supplementsInfoResponse.data.map((element) => SupplementInfoEntity(id: element.id, es: element.es, en: element.en, unit: element.unit, computerName: element.computerName)).toList();
  return SupplementsInfoEntity(v: supplementsInfoResponse.v, data: data);
}

SupplementsInfoMaster mapToSupplementsInfoMaster(SupplementsInfoEntity supplementsInfoEntity) {
  List<SupplementInfoMaster> data = supplementsInfoEntity.data.map((element) => SupplementInfoMaster(id: element.id, es: element.es, en: element.en, unit: element.unit, computerName: element.computerName)).toList();
  return SupplementsInfoMaster(v: supplementsInfoEntity.v, data: data);
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

CookingMethodsOilsInfoEntity mapToCookingMethodsOilsInfoEntity(CookingMethodsOilsInfoResponse response) {
  List<CookingMethodOilInfoEntity> data = response.data.map((item) => CookingMethodOilInfoEntity(id: item.id, name: item.name, percentage: item.percentage)).toList();
  return CookingMethodsOilsInfoEntity(id: MasterFilesType.cookingMethodsOilsInfo.index, v: response.v, data: data);
}