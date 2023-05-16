import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_today_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';

class GetTodaySportsInteractorImpl extends GetTodaySportsInteractor {
  final SportEventsRepository sportEventsRepository;

  GetTodaySportsInteractorImpl({required this.sportEventsRepository});

  @override
  Future<List<SportEventComplete>> execute() => sportEventsRepository.getTodaySportEvents();
}