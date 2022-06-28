import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class MasterFilesApi extends ApiHelper {

  MasterFilesApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService) : super(preferencesRepository, authenticationService);

  Future<Map<String, dynamic>> manageMasterFiles(
      int cookingMethodsVersion,
      int cookingMethodsInfoVersion,
      int foodsAndDrinksNamesVersion,
      int nutrientsInfoVersion,
      int objectivesInfoVersion,
      int recommendationGroupsVersion,
      int sportsInfoVersion
  ) {
    return get(
      Uri.https(
        Environment().config!.baseUrl,
        '/dev/manage-master-files',
        {
          cookingMethods: cookingMethodsVersion.toString(),
          cookingMethodsInfo: cookingMethodsInfoVersion.toString(),
          foodsAndDrinksNames: foodsAndDrinksNamesVersion.toString(),
          nutrientsInfo: nutrientsInfoVersion.toString(),
          objectivesInfo: objectivesInfoVersion.toString(),
          recommendationGroups: recommendationGroupsVersion.toString(),
          sportsInfo: sportsInfoVersion.toString(),
        },
      ),
    );
  }
}