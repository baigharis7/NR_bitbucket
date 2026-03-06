import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class SportEventsApi extends ApiHelper {

  SportEventsApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  /// Save pre-computed sport event to DynamoDB (simple write, no server-side computation).
  Future<Map<String, dynamic>> saveSportEvent(SportEventComplete sportEventComplete) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/sport-event',
        ),
        sportEventComplete,
      );

  Future<Map<String, dynamic>> deleteSportEvent(String userId, int eventId) =>
      delete(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/sport-event',
        ),
        {
          'userId': userId,
          'eventId': eventId,
        },
      );

}