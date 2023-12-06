import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';

import '../../../domain/models/foodevents/food_event_complete.dart';

class CalendarActions {
  CalendarActions();
}

class InitializeStateAction extends CalendarActions {
  InitializeStateAction();
}

class SelectDayEventsActions extends CalendarActions {
  final DateTime selectedDay;

  SelectDayEventsActions({required this.selectedDay});
}

class RefreshEventsAction extends CalendarActions {
  final DateTime selectedDay;

  RefreshEventsAction({required this.selectedDay});
}

class RemoveFoodEventAction extends CalendarActions {
  final FoodEventComplete foodEventComplete;
  final Function onFinish;

  RemoveFoodEventAction({required this.foodEventComplete, required this.onFinish});
}

class RemoveSportEventAction extends CalendarActions {
  final SportEventComplete sportEventComplete;
  final Function onFinish;

  RemoveSportEventAction({required this.sportEventComplete, required this.onFinish});
}