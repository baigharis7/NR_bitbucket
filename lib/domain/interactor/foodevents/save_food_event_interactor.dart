import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';

abstract class SaveFoodEventInteractor {
  Future<void> execute(UploadFoodEvent uploadFoodEvent);
}