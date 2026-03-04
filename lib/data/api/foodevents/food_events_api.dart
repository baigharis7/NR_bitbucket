import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class FoodEventsApi extends ApiHelper {

  FoodEventsApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  /// Save pre-computed food event to DynamoDB (simple write, no server-side computation).
  Future<Map<String, dynamic>> saveFoodEvent(UploadFoodEvent uploadFoodEvent) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/food-event',
        ),
        uploadFoodEvent,
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