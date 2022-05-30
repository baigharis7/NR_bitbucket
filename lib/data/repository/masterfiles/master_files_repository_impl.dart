import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
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

}