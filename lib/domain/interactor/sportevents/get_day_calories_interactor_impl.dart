import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_day_calories_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';

class GetDayCaloriesInteractorImpl extends GetDayCaloriesInteractor {
  final SportEventsRepository sportEventsRepository;

  GetDayCaloriesInteractorImpl({
    required this.sportEventsRepository,
  });

  @override
  Future<int?> execute() async => await sportEventsRepository.getDayCalories();

}