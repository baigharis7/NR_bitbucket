import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';

abstract class UploadSportEventsInteractor {
  Future<SportEventComplete> execute(SportEventSimple sportEventSimple);
}