import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';

abstract class MasterFilesRepository {
  FoodsAndDrinksNamesMaster? getFoodsAndDrinksNames();
  Future<int> getMasterFileVersion(MasterFilesType masterFileType);
  Future<MasterFilesResponse> manageMasterFiles(
      int cookingMethodsVersion,
      int cookingMethodsInfoVersion,
      int foodsAndDrinksNamesVersion,
      int nutrientsInfoVersion,
      int objectivesInfoVersion,
      int recommendationGroupsVersion
  );
  Future<void> saveMasterFile(dynamic masterFileResponse, MasterFilesType masterFilesType);
  Future<dynamic> getMasterFile(MasterFilesType masterFilesType);

}