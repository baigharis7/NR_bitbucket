import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_all_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';

class GetAllFoodEventsInteractorImpl extends GetAllFoodEventsInteractor {
  final FoodEventsRepository foodEventsRepository;

  GetAllFoodEventsInteractorImpl({required this.foodEventsRepository});

  @override
  Future<List<FoodEventComplete>>? execute() async => await foodEventsRepository.getAllFoodEvents();

}