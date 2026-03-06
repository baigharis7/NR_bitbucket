import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class MasterFilesApi extends ApiHelper {

  MasterFilesApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> manageMasterFiles(
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
      int cookingMethodsOilsInfoVersion,
  ) {
    return get(
      Uri.https(
        Environment().config!.baseUrl,
        '${Environment().config!.distributionPath}/manage-master-files',
        {
          cookingMethods: cookingMethodsVersion.toString(),
          cookingMethodsInfo: cookingMethodsInfoVersion.toString(),
          conversionFactors: conversionFactorsVersion.toString(),
          conversionFactorsInfo: conversionFactorsInfoVersion.toString(),
          oilTypes: oilTypesVersion.toString(),
          foodsAndDrinksNames: foodsAndDrinksNamesVersion.toString(),
          nutrientsInfo: nutrientsInfoVersion.toString(),
          objectivesInfo: objectivesInfoVersion.toString(),
          recommendationGroups: recommendationGroupsVersion.toString(),
          sportsInfo: sportsInfoVersion.toString(),
          unitsInfo: unitsInfoVersion.toString(),
          unitsFoods: unitsFoodsVersion.toString(),
          supplementsInfo: supplementsInfoVersion.toString(),
          subjectiveAnalysis: subjectiveAnalysisVersion.toString(),
          cookingMethodsOilsInfo: cookingMethodsOilsInfoVersion.toString(),
        },
      ),
    );
  }
}