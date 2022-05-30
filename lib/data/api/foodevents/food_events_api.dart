import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class FoodEventsApi extends ApiHelper {

  FoodEventsApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService) : super(preferencesRepository, authenticationService);

  Future<Map<String, dynamic>> uploadFoodEvent(FoodEventSimple foodEventSimple) =>
      post(
        Uri.https(
            Environment().config!.baseUrl,
            '/dev/food-event/amplify',
        ),
        foodEventSimple,
      );

}