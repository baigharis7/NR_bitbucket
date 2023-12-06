import '../../models/sportevents/sport_event_complete.dart';

abstract class RemoveSportEventInteractor {
  Future<void> execute(SportEventComplete sportEventComplete);
}