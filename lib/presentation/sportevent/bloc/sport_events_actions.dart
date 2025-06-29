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
  final AddSportFavInfo sportInfo;

  SetIntensityAction({required this.sportInfo});
}

class SetMinutesAction extends SportEventsActions {
  final AddSportFavInfo sportInfo;

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

class ResetSportInfoAction extends SportEventsActions {
  ResetSportInfoAction();
}

class AddSportEventAction extends SportEventsActions {
  final AddSportFavInfo sportInfo;

  AddSportEventAction(this.sportInfo);
}

class RemoveSportEventAction extends SportEventsActions {
  AddSportFavInfo sportInfo;

  RemoveSportEventAction({required this.sportInfo});
}

class SetEventSportNameAction extends SportEventsActions {
  final String sportEventName;

  SetEventSportNameAction({required this.sportEventName});
}

class UpdateCalendarDateSportEventAction extends SportEventsActions {
  final DateTime? calendarDate;

  UpdateCalendarDateSportEventAction({required this.calendarDate});
}

class UpdateDaysOfWeekSportEventAction extends SportEventsActions {
  final int weekDay;

  UpdateDaysOfWeekSportEventAction({required this.weekDay});
}

class UpdateTimeOfDaySportEventAction extends SportEventsActions {
  final String scheduleTime;

  UpdateTimeOfDaySportEventAction({required this.scheduleTime});
}