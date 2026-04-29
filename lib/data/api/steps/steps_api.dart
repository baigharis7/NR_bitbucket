import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:nutrenaissance_flutter/data/api/steps/models/upload_step_event_response.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

import '../../../domain/repository/preferences/preferences_repository.dart';
import '../../../infrastructure/authentication/authentication_service.dart';
import '../../../infrastructure/environment/environment.dart';

class StepsApi extends ApiHelper {
  StepsApi(PreferencesRepository preferencesRepository,
      AuthenticationService authenticationService, Chuck chuck)
      : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> uploadSteps(UploadStepEventResponse uploadStepEventResponse) => post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/steps-count',
        ),
        uploadStepEventResponse,
      );
}
