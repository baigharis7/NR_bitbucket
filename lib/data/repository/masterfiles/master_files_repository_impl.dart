import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/nutrients_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/objectives_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/recommendation_groups_entity.dart';
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
      int foodsAndDrinksNamesVersion,
      int nutrientsInfoVersion,
      int objectivesInfoVersion,
      int recommendationGroupsVersion
  ) async {
    final response = await masterFilesApi.manageMasterFiles(
      cookingMethodsVersion,
      cookingMethodsInfoVersion,
      foodsAndDrinksNamesVersion,
      nutrientsInfoVersion,
      objectivesInfoVersion,
      recommendationGroupsVersion,
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
    switch (masterFilesType) {
      case MasterFilesType.cookingMethods:
        return mapToCookingMethodsMaster(masterFileEntity as CookingMethodsEntity);
      case MasterFilesType.cookingMethodsInfo:
        return mapToCookingMethodsInfoMaster(masterFileEntity as CookingMethodsInfoEntity);
      case MasterFilesType.foodsAndDrinksNames:
        return mapToFoodsAndDrinksNamesMaster(masterFileEntity as FoodsAndDrinksNamesEntity);
      case MasterFilesType.nutrientsInfo:
        return mapToNutrientsInfoMaster(masterFileEntity as NutrientsInfoEntity);
      case MasterFilesType.objectivesInfo:
        return mapToObjectivesInfoMaster(masterFileEntity as ObjectivesInfoEntity);
      case MasterFilesType.recommendationGroups:
        return mapToRecommendationGroupsMaster(masterFileEntity as RecommendationGroupsEntity);
    }
  }

}