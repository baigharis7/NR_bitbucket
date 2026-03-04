import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/data/api/liquidevents/model/upload_liquid_event.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class LiquidEventsApi extends ApiHelper {
  LiquidEventsApi(PreferencesRepository preferencesRepository,
      AuthenticationService authenticationService, Chuck chuck)
      : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> saveLiquidEvent(
          UploadLiquidEvent uploadLiquidEvent) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/liquid-event',
        ),
        uploadLiquidEvent,
      );

  Future<Map<String, dynamic>> deleteLiquidEvent(String userId, int eventDate) =>
      delete(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/liquid-event',
        ),
        {
          'userId': userId,
          'eventDate': eventDate,
        },
      );
}
