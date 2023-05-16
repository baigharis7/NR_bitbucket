import 'package:nutrenaissance_flutter/data/api/profile/model/simple_user.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class ProfileApi extends ApiHelper {

  ProfileApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService) : super(preferencesRepository, authenticationService);

  Future<Map<String, dynamic>> uploadProfileApi(UploadUserProfile body) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/profile-data',
        ),
        body,
      );

  Future<Map<String, dynamic>> downloadProfile(String email) =>
      get(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/users',
            {'email': email},
        ),
      );

  Future<Map<String, dynamic>> saveUser(SimpleUser simpleUser) =>
      post(
        Uri.https(
            Environment().config!.baseUrl,
            '${Environment().config!.distributionPath}/users',
        ),
        simpleUser,
      );
}
