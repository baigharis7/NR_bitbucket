import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/remove_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';

import '../../models/foodevents/food_event_complete.dart';

class ReomveFoodEventInteractorImpl extends RemoveFoodEventInteractor {
  final FoodEventsRepository foodEventsRepository;

  ReomveFoodEventInteractorImpl({required this.foodEventsRepository});

  @override
  Future<bool> execute(FoodEventComplete foodEventComplete) => foodEventsRepository.removeFoodEvent(foodEventComplete);

}