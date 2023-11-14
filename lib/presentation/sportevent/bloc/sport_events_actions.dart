import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';

class SportEventsActions {
  SportEventsActions();
}

class InitializeStateAction extends SportEventsActions {
  InitializeStateAction();
}

class SetIntensityAction extends SportEventsActions {
  final SportInfo sportInfo;
  String currentLanguage;

  SetIntensityAction({required this.sportInfo, required this.currentLanguage,});
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

class RemoveSportEventAction extends SportEventsActions {
  SportInfo sportInfo;

  RemoveSportEventAction({required this.sportInfo});
}