import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:nutrenaissance_flutter/data/api/sleepevents/models/upload_sleep_event.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

import '../../../domain/repository/preferences/preferences_repository.dart';
import '../../../infrastructure/authentication/authentication_service.dart';
import '../../../infrastructure/environment/environment.dart';

class SleepEventsApi extends ApiHelper {
  SleepEventsApi(PreferencesRepository preferencesRepository,
      AuthenticationService authenticationService, Chuck chuck)
      : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> uploadSleepEvent(UploadSleepEvent uploadSleepEvent) => post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/sleep-event',
        ),
        uploadSleepEvent,
      );
}
