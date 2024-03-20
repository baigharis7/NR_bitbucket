import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

import '../../../infrastructure/environment/environment.dart';

class SupplementApi extends ApiHelper {

  SupplementApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> uploadCreatineEvent(UploadSupplementEvent uploadSupplementEvent) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/creatine',
        ),
        uploadSupplementEvent,
      );

}