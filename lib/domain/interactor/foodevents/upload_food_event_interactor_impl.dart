import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';

class UploadFoodEventInteractorImpl extends UploadFoodEventInteractor {
  final FoodEventsRepository foodEventsRepository;

  UploadFoodEventInteractorImpl({required this.foodEventsRepository});

  @override
  Future<UploadFoodEvent> execute(FoodEventSimple foodEventSimple) => foodEventsRepository.uploadFoodEvent(foodEventSimple);
}