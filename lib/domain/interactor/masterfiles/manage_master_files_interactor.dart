import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';

abstract class ManageMasterFilesInteractor {
  Future<MasterFilesResponse> execute(
      int cookingMethodsInfoVersion,
      int cookingMethodsVersion,
      int oilTypesVersion,
      int conversionFactorsVersion,
      int conversionFactorsInfoVersion,
      int foodsAndDrinksNamesVersion,
      int nutrientsInfoVersion,
      int objectivesInfoVersion,
      int recommendationGroupsVersion,
      int sportsInfoVersion,
      int unitsInfoVersion,
      int unitsFoodsVersion,
      int subjectiveAnalysisVersion,
  );
}