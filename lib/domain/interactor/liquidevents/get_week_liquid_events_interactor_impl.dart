import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';

class GetWeekLiquidEventsInteractorImpl extends GetWeekLiquidEventsInteractor {
  final LiquidEventsRepository liquidEventsRepository;

  GetWeekLiquidEventsInteractorImpl({required this.liquidEventsRepository});

  @override
  Future<List<FoodEventComplete>> execute() => liquidEventsRepository.getWeeklyLiquidEvents();

}