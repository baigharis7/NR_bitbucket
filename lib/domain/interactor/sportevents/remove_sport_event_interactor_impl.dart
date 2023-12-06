import 'package:nutrenaissance_flutter/domain/interactor/sportevents/remove_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';

class RemoveSportEventInteractorImpl extends RemoveSportEventInteractor {
  final SportEventsRepository sportEventsRepository;

  RemoveSportEventInteractorImpl({required this.sportEventsRepository});

  @override
  Future<void> execute(SportEventComplete sportEventComplete) async =>
      await sportEventsRepository.removeSportEvent(sportEventComplete);
}
