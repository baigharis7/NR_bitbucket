import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class EventsSyncApi extends ApiHelper {

  EventsSyncApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> sendEventsIds(
    String userId,
    List<String> foodEvents,
    List<String> sportEvents,
    List<String> sportRoutines,
    List<String> liquidEvents,
    List<String> waterEvents,
    List<String> foodFavorites,
    List<String> sportFavorites,
    List<String> liquidFavorites,
    List<String> subjectiveAnalysis,
    List<String> recipeFavorites,
    List<String> fecesEvents,
    List<String> urineEvents,
    List<String> creatineEvents,
    List<String> collagenEvents,
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
        'sportRoutines': sportRoutines,
        'liquidEvents': liquidEvents,
        'waterEvents': waterEvents,
        'foodFavorites': foodFavorites,
        'sportFavorites': sportFavorites,
        'liquidFavorites': liquidFavorites,
        'subjectiveAnalysis': subjectiveAnalysis,
        'recipeFavorites': recipeFavorites,
        'fecesEvents': fecesEvents,
        'urineEvents': urineEvents,
        'creatineEvents': creatineEvents,
        'collagenEvents': collagenEvents,
      },
    );
  }
}