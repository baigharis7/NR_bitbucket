import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/conversion_factors_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/conversion_factors_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
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
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/master_files_mapper.dart';

class MasterFilesRepositoryImpl extends MasterFilesRepository {
  final LocalStorageRepository localStorageRepository;
  final MasterFilesApi masterFilesApi;

  MasterFilesRepositoryImpl({required this.localStorageRepository, required this.masterFilesApi});

  @override
  FoodsAndDrinksNamesMaster? getFoodsAndDrinksNames() {
    return null;
  }

  @override
  Future<int> getMasterFileVersion(MasterFilesType masterFileType) async =>
      localStorageRepository.getMasterFileVersion(masterFileType);

  @override
  Future<MasterFilesResponse> manageMasterFiles(
      int cookingMethodsVersion,
      int cookingMethodsInfoVersion,
      int conversionFactorsVersion,
      int conversionFactorsInfoVersion,
      int oilTypesVersion,
      int foodsAndDrinksNamesVersion,
      int nutrientsInfoVersion,
      int objectivesInfoVersion,
      int recommendationGroupsVersion,
      int sportsInfoVersion,
      int unitsInfoVersion,
      int unitsFoodsVersion,
      int supplementsInfoVersion,
      int subjectiveAnalysisVersion,
  ) async {
    final response = await masterFilesApi.manageMasterFiles(
      cookingMethodsVersion,
      cookingMethodsInfoVersion,
      conversionFactorsVersion,
      conversionFactorsInfoVersion,
      oilTypesVersion,
      foodsAndDrinksNamesVersion,
      nutrientsInfoVersion,
      objectivesInfoVersion,
      recommendationGroupsVersion,
      sportsInfoVersion,
      unitsInfoVersion,
      unitsFoodsVersion,
      supplementsInfoVersion,
      subjectiveAnalysisVersion,
    );
    if (response.isNotEmpty) {
      return MasterFilesResponse.fromJson(response);
    } else {
      return MasterFilesResponse();
    }
  }

  @override
  Future<void> saveMasterFile(dynamic masterFileResponse, MasterFilesType masterFilesType) {
    final masterFileEntity = mapToMasterFileEntity(masterFileResponse, masterFilesType);
    return localStorageRepository.saveMasterFile(masterFilesType, masterFileEntity);
  }

  @override
  Future getMasterFile(MasterFilesType masterFilesType) async {
    final masterFileEntity = await localStorageRepository.getMasterFile(masterFilesType);
    if (masterFileEntity == null) return null;
    switch (masterFilesType) {
      case MasterFilesType.cookingMethods:
        return mapToCookingMethodsMaster(masterFileEntity as CookingMethodsEntity);
      case MasterFilesType.cookingMethodsInfo:
        return mapToCookingMethodsInfoMaster(masterFileEntity as CookingMethodsInfoEntity);
      case MasterFilesType.oilTypes:
        return mapToOilTypesResponse(masterFileEntity as OilTypesEntity);
      case MasterFilesType.conversionFactors:
        return mapToConversionFactorsResponse(masterFileEntity as ConversionFactorsEntity);
      case MasterFilesType.conversionFactorsInfo:
        return mapToConversionFactorsInfoResponse(masterFileEntity as ConversionFactorsInfoEntity);
      case MasterFilesType.foodsAndDrinksNames:
        return mapToFoodsAndDrinksNamesMaster(masterFileEntity as FoodsAndDrinksNamesEntity);
      case MasterFilesType.nutrientsInfo:
        return mapToNutrientsInfoMaster(masterFileEntity as NutrientsInfoEntity);
      case MasterFilesType.objectivesInfo:
        return mapToObjectivesInfoMaster(masterFileEntity as ObjectivesInfoEntity);
      case MasterFilesType.recommendationGroups:
        return mapToRecommendationGroupsMaster(masterFileEntity as RecommendationGroupsEntity);
      case MasterFilesType.sportsInfo:
        return mapToSportsInfoMaster(masterFileEntity as SportsInfoEntity);
      case MasterFilesType.unitsInfo:
        return mapToUnitsInfoMaster(masterFileEntity as UnitsInfoEntity);
      case MasterFilesType.unitsFoods:
        return mapToUnitsFoodsMaster(masterFileEntity as UnitsFoodsEntity);
      case MasterFilesType.supplementsInfo:
        return mapToSupplementsInfoMaster(masterFileEntity as SupplementsInfoEntity);
      case MasterFilesType.subjectiveAnalysis:
        return mapToSubjectiveAnalysisMaster(masterFileEntity as SubjectiveAnalysisListEntity);
    }
  }

}