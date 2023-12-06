import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class FoodEventsApi extends ApiHelper {

  FoodEventsApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> uploadFoodEvent(FoodEventSimple foodEventSimple) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/food-event/amplify',
        ),
        foodEventSimple,
      );

  Future<Map<String, dynamic>> deleteFoodEvent(String userId, int eventDate) =>
      delete(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/food-event',
        ),
        {
          'userId': userId,
          'eventId': eventDate
        },
      );

}