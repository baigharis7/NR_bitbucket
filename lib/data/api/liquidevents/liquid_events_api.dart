import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class LiquidEventsApi extends ApiHelper {
  LiquidEventsApi(PreferencesRepository preferencesRepository,
      AuthenticationService authenticationService, Chuck chuck)
      : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> uploadLiquidEvent(
          LiquidEventSimple liquidEventSimple) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/liquid-event/amplify',
        ),
        liquidEventSimple,
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
