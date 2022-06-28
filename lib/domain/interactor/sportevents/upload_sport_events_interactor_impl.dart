import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';

class UploadSportEventsInteractorImpl extends UploadSportEventsInteractor {
  final SportEventsRepository sportEventsRepository;

  UploadSportEventsInteractorImpl({required this.sportEventsRepository});

  @override
  Future<SportEventComplete> execute(SportEventSimple sportEventSimple) => sportEventsRepository.uploadSportEvent(sportEventSimple);

}