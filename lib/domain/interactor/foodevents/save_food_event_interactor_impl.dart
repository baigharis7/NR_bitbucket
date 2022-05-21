import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';

class SaveFoodEventInteractorImpl extends SaveFoodEventInteractor {
  final FoodEventsRepository foodEventsRepository;

  SaveFoodEventInteractorImpl({required this.foodEventsRepository});

  @override
  Future<void> execute(UploadFoodEvent uploadFoodEvent) => foodEventsRepository.saveFoodEvent(uploadFoodEvent);

}