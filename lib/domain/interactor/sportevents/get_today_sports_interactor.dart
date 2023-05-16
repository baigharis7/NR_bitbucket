import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';

abstract class GetTodaySportsInteractor {
  Future<List<SportEventComplete>> execute();
}