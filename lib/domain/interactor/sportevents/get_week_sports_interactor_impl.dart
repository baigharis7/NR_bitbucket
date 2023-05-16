import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';

class GetWeekSportsInteractorImpl extends GetWeekSportsInteractor {
  final SportEventsRepository sportEventsRepository;

  GetWeekSportsInteractorImpl({required this.sportEventsRepository});

  @override
  Future<List<SportEventComplete>> execute() async => await sportEventsRepository.getWeeklySportEvents();

}