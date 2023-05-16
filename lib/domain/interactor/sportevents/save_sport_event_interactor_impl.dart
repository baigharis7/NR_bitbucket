import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';

class SaveSportEventInteractorImpl extends SaveSportEventInteractor {
  final SportEventsRepository sportEventsRepository;

  SaveSportEventInteractorImpl({required this.sportEventsRepository});

  @override
  Future<void> execute(SportEventComplete sportEventComplete, bool isEdit) => sportEventsRepository.saveSportEvent(sportEventComplete, isEdit);

}