import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class MasterFilesApi extends ApiHelper {

  MasterFilesApi(
      {
        required GetIdTokenInteractor getIdTokenInteractor,
        required FetchUserAttributesInteractor fetchUserAttributesInteractor
      }
  ) : super(
      getIdTokenInteractor,
      fetchUserAttributesInteractor
  );

  Future<Map<String, dynamic>> manageMasterFiles(
      int cookingMethodsVersion,
      int cookingMethodsInfoVersion,
      int foodsAndDrinksNamesVersion,
      int nutrientsInfoVersion,
      int objectivesInfoVersion,
      int recommendationGroupsVersion
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
        },
      ),
    );
  }
}