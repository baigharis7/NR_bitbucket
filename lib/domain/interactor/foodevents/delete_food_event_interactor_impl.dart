import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';

import '../../models/foodevents/food_event_complete.dart';
import 'delete_food_event_interactor.dart';

class DeleteFoodEventInteractorImpl extends DeleteFoodEventInteractor {
  final FoodEventsRepository foodEventsRepository;

  DeleteFoodEventInteractorImpl({required this.foodEventsRepository});

  @override
  Future<bool> execute(String userId, int eventDate) => foodEventsRepository.deleteFoodEvent(userId, eventDate);

}