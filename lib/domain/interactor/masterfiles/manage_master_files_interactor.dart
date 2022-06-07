import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';

abstract class ManageMasterFilesInteractor {
  Future<MasterFilesResponse> execute(
      int cookingMethodsInfoVersion,
      int cookingMethodsVersion,
      int foodsAndDrinksNamesVersion,
      int nutrientsInfoVersion,
      int objectivesInfoVersion,
      int recommendationGroupsVersion,
  );
}