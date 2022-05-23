import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/local/local_storage_helper.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';

class MasterFilesRepositoryImpl extends MasterFilesRepository {
  final LocalStorageHelper localStorageHelper;
  final MasterFilesApi masterFilesApi;

  MasterFilesRepositoryImpl({required this.localStorageHelper, required this.masterFilesApi});

  @override
  FoodAndDrinksNamesMaster? getFoodAndDrinksNames() {
    return null;
  }

  @override
  Future<int> getMasterFileVersion(MasterFilesType masterFileType) async =>
      localStorageHelper.getMasterFileVersion(masterFileType);

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

}