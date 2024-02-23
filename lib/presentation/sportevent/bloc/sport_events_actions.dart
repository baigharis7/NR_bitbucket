import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';

import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';

class SportEventsActions {
  SportEventsActions();
}

class InitializeStateAction extends SportEventsActions {
  InitializeStateAction();
}

class SetIntensityAction extends SportEventsActions {
  final SportInfo sportInfo;

  SetIntensityAction({required this.sportInfo});
}

class SetSportNameAction extends SportEventsActions {
  String sportName;
  int sportId;
  String currentLanguage;

  SetSportNameAction({required this.sportName, required this.sportId, required this.currentLanguage});
}

class SetDateStartAction extends SportEventsActions {
  // final DateTime dateStart;

  SetDateStartAction();
}

class SetTimeStartAction extends SportEventsActions {
  final SportInfo sportInfo;

  SetTimeStartAction({required this.sportInfo});
}

class SetMinutesAction extends SportEventsActions {
  final SportInfo sportInfo;

  SetMinutesAction({required this.sportInfo});
}

class FinishSportEventAction extends SportEventsActions {
  Function onFinish;

  FinishSportEventAction({required this.onFinish});
}

class FinishSportFavoriteAction extends SportEventsActions {
  Function onFinish;

  FinishSportFavoriteAction({required this.onFinish});
}

class ReceiveSportEventInfoAction extends SportEventsActions {
  SportEventSimple sportEventSimple;
  BuildContext context;

  ReceiveSportEventInfoAction({required this.sportEventSimple, required this.context});
}

class ResetSportInfoAction extends SportEventsActions {
  ResetSportInfoAction();
}

class ReceiveEventDateAction extends SportEventsActions {
  final DateTime eventDate;

  ReceiveEventDateAction({required this.eventDate});
}

class AddSportEventAction extends SportEventsActions {
  final SportInfo sportInfo;

  AddSportEventAction(this.sportInfo);
}

class AddSportFromFavoriteAction extends SportEventsActions {
  final AddSportFavorite sportInfo;

  AddSportFromFavoriteAction({required this.sportInfo});
}

class RemoveSportEventAction extends SportEventsActions {
  SportInfo sportInfo;

  RemoveSportEventAction({required this.sportInfo});
}

class SetEventSportNameAction extends SportEventsActions {
  final String sportEventName;

  SetEventSportNameAction({required this.sportEventName});
}

class AddSportEventFromDetailNavigation extends SportEventsActions {
  final SportEventComplete sportEventComplete;

  AddSportEventFromDetailNavigation({required this.sportEventComplete});
}

class UpdateCreateRoutine extends SportEventsActions {}

class UpdateRoutineHourEventAction extends SportEventsActions {
  final TimeOfDay? timeOfDay;

  UpdateRoutineHourEventAction({required this.timeOfDay});
}

class UpdateRoutineDateEventAction extends SportEventsActions {
  final DateTime? dateTime;

  UpdateRoutineDateEventAction({required this.dateTime});
}

class FinishCreateRoutineEventAction extends SportEventsActions {
  final Function onFinish;

  FinishCreateRoutineEventAction({required this.onFinish});
}

class FinishWithoutRoutineEventAction extends SportEventsActions {
  final Function onFinish;
  final BuildContext context;

  FinishWithoutRoutineEventAction({required this.onFinish, required this.context});
}

class AddSportRoutineFromRoutineEventAction extends SportEventsActions {
  final SportRoutineCompleted sportRoutineCompleted;

  AddSportRoutineFromRoutineEventAction({required this.sportRoutineCompleted});
}