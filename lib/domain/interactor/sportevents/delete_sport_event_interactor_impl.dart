import 'package:nutrenaissance_flutter/domain/interactor/sportevents/delete_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';

class DeleteSportEventInteractorImpl extends DeleteSportEventInteractor {
  final SportEventsRepository sportEventsRepository;

  DeleteSportEventInteractorImpl({required this.sportEventsRepository});

  @override
  Future<void> execute(String userId, int eventId) async => await sportEventsRepository.deleteSportEvent(userId, eventId);

}