import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class EventsSyncApi extends ApiHelper {

  EventsSyncApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService) : super(preferencesRepository, authenticationService);

  Future<Map<String, dynamic>> sendEventsIds(
    String userId,
    List<String> foodEvents,
    List<String> sportEvents,
    List<String> liquidEvents,
    List<String> waterEvents,
    List<String> foodFavorites,
    List<String> sportFavorites,
    List<String> liquidFavorites,
    List<String> subjectiveAnalysis,
  ) {
    return post(
      Uri.https(
        Environment().config!.baseUrl,
        '${Environment().config!.distributionPath}/events-sync',
      ),
      {
        'userId' : userId,
        'foodEvents': foodEvents,
        'sportEvents': sportEvents,
        'liquidEvents': liquidEvents,
        'waterEvents': waterEvents,
        'foodFavorites': foodFavorites,
        'sportFavorites': sportFavorites,
        'liquidFavorites': liquidFavorites,
        'subjectiveAnalysis': subjectiveAnalysis,
      },
    );
  }
}