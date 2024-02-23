import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

import '../../../domain/repository/preferences/preferences_repository.dart';
import '../../../infrastructure/authentication/authentication_service.dart';
import '../../../infrastructure/environment/environment.dart';

class RoutinesApi extends ApiHelper {
  RoutinesApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> uploadRoutine(SportRoutineCompleted sportRoutineCompleted) => post(
    Uri.https(
      Environment().config!.baseUrl,
      '${Environment().config!.distributionPath}/sport-routine',
    ),
    sportRoutineCompleted,
  );

  Future<Map<String, dynamic>> deleteSportRoutine(String userId, int eventId) => delete(
    Uri.https(
      Environment().config!.baseUrl,
    '${Environment().config!.distributionPath}/sport-routine',
    ),
    {
      'userId': userId,
      'eventId': eventId,
    },
  );
}