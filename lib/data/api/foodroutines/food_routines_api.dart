import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';

import '../../../domain/repository/preferences/preferences_repository.dart';
import '../../../infrastructure/authentication/authentication_service.dart';
import '../../../infrastructure/environment/environment.dart';
import '../../../infrastructure/http/api_helper.dart';

class FoodRoutinesApi extends ApiHelper {
  FoodRoutinesApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> uploadRoutine(FoodRoutineEvent foodRoutineEvent) => post(
    Uri.https(
      Environment().config!.baseUrl,
      '${Environment().config!.distributionPath}/food-routines',
    ),
    foodRoutineEvent,
  );

  Future<Map<String, dynamic>> deleteRoutine(FoodRoutineEvent foodRoutineEvent) => delete(
    Uri.https(
      Environment().config!.baseUrl,
      '${Environment().config!.distributionPath}/food-routines',
    ),
    {
      'userId': foodRoutineEvent.userId,
      'eventId': foodRoutineEvent.eventId,
    },
  );
}