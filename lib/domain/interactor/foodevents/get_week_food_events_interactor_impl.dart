import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';

class GetWeekFoodEventsInteractorImpl extends GetWeekFoodEventsInteractor {
  final FoodEventsRepository foodEventsRepository;

  GetWeekFoodEventsInteractorImpl({required this.foodEventsRepository});

  @override
  Future<List<FoodEventComplete>> execute() async => foodEventsRepository.getWeekFoodEvents();
}