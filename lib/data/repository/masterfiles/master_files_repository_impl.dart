import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';

class MasterFilesRepositoryImpl extends MasterFilesRepository {
  final LocalStorageRepository localStorageRepository;
  final MasterFilesApi masterFilesApi;

  MasterFilesRepositoryImpl({required this.localStorageRepository, required this.masterFilesApi});

  @override
  FoodAndDrinksNamesMaster? getFoodAndDrinksNames() {
    return null;
  }

  @override
  Future<int> getMasterFileVersion(MasterFilesType masterFileType) async =>
      localStorageRepository.getMasterFileVersion(masterFileType);

  @override
  Future<MasterFilesResponse> manageMasterFiles(
      int cookingMethodsInfoVersion,
      int cookingMethodsVersion,
      int foodAndDrinksNamesVersion,
      int nutrientsInfoVersion,
      int objectivesInfoVersion,
      int recommendationGroupsVersion
  ) async {
    return MasterFilesResponse.fromJson(
        await masterFilesApi.manageMasterFiles(
            cookingMethodsInfoVersion, cookingMethodsVersion,
            foodAndDrinksNamesVersion,
            nutrientsInfoVersion,
            objectivesInfoVersion,
            recommendationGroupsVersion,
        ),
    );
  }

  @override
  Future<void> saveMasterFile(dynamic masterFile, MasterFilesType masterFilesType) => localStorageRepository.saveMasterFile(masterFilesType.index, masterFile);

}