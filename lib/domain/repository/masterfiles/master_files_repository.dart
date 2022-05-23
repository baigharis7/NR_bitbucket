import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';

abstract class MasterFilesRepository {
  FoodAndDrinksNamesMaster? getFoodAndDrinksNames();
  Future<int> getMasterFileVersion(MasterFilesType masterFileType);
  Future<MasterFilesResponse> manageMasterFiles(
      int cookingMethodsInfoVersion,
      int cookingMethodsVersion,
      int foodAndDrinksNamesVersion,
      int nutrientsInfoVersion,
      int objectivesInfoVersion,
      int recommendationGroupsVersion
  );
}