import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_food_events_of_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';

class GetFoodEventsOfTodayInteractorImpl extends GetFoodEventsOfTodayInteractor {
  final FoodEventsRepository foodEventsRepository;

  GetFoodEventsOfTodayInteractorImpl({required this.foodEventsRepository});

  @override
  Future<List<FoodEventComplete>> execute({DateTime? dateTime}) async => await foodEventsRepository.getFoodEventsOfToday(dateTime: dateTime);

}