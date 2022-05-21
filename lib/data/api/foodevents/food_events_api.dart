import '../../../domain/interactor/login/fetch_user_attributes_interactor.dart';
import '../../../domain/interactor/preferences/get_id_token_interactor.dart';
import '../../../domain/models/foodevents/food_event_simple.dart';
import '../../../infrastructure/environment/environment.dart';
import '../../../infrastructure/http/api_helper.dart';

class FoodEventsApi extends ApiHelper {
  FoodEventsApi({
    required GetIdTokenInteractor getIdTokenInteractor,
    required FetchUserAttributesInteractor fetchUserAttributesInteractor
  }) : super(getIdTokenInteractor, fetchUserAttributesInteractor);

  Future<Map<String, dynamic>> uploadFoodEvent(FoodEventSimple foodEventSimple) =>
      post(
        Uri.https(
            Environment().config!.baseUrl,
            '/dev/food-event/amplify',
        ),
        foodEventSimple,
      );

}