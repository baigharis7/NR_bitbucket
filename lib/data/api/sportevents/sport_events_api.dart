import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class SportEventsApi extends ApiHelper {

  SportEventsApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> uploadSportEvent(SportEventSimple sportEventSimple) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/sport-event/amplify',
        ),
        sportEventSimple,
      );

}