import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';

class SportEventsActions {
  SportEventsActions();
}

class InitializeStateAction extends SportEventsActions {
  InitializeStateAction();
}

class SetIntensityAction extends SportEventsActions {
  int intensity;
  String currentLanguage;

  SetIntensityAction({required this.intensity, required this.currentLanguage,});
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
  final TimeOfDay timeStart;

  SetTimeStartAction({required this.timeStart});
}

class SetMinutesAction extends SportEventsActions {
  final int minutes;

  SetMinutesAction({required this.minutes});
}

class FinishSportEventAction extends SportEventsActions {
  Function onFinish;

  FinishSportEventAction({required this.onFinish});
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