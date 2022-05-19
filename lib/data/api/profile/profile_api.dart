import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class ProfileApi extends ApiHelper {

  ProfileApi({
    required GetIdTokenInteractor getIdTokenInteractor,
    required FetchUserAttributesInteractor fetchUserAttributesInteractor
  }) : super(
      getIdTokenInteractor,
      fetchUserAttributesInteractor
  );

  Future<Map<String, dynamic>> uploadProfileApi(UploadUserProfile body) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '/dev/profile-data',
        ),
        body,
      );
}