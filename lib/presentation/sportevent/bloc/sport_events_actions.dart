import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_arguments_model.dart';

import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../domain/models/routines/sport_routine_completed.dart';

class SportEventsActions {
  SportEventsActions();
}

class InitializeStateAction extends SportEventsActions {
  InitializeStateAction();
}

class UpdateCalendarDateSportEventAction extends SportEventsActions {
  final DateTime? calendarDate;

  UpdateCalendarDateSportEventAction({required this.calendarDate});
}

class AddSportArgumentModelEventAction extends SportEventsActions {
  final SportArgumentsModel sportArgumentsModel;

  AddSportArgumentModelEventAction({required this.sportArgumentsModel});
}

class AddSportEventAction extends SportEventsActions {
  final AddSportFavInfo sportInfo;

  AddSportEventAction(this.sportInfo);
}

class RemoveSportEventAction extends SportEventsActions {
  AddSportFavInfo sportInfo;

  RemoveSportEventAction({required this.sportInfo});
}

class SetIntensityAction extends SportEventsActions {
  final AddSportFavInfo sportInfo;

  SetIntensityAction({required this.sportInfo});
}

class SetMinutesAction extends SportEventsActions {
  final AddSportFavInfo sportInfo;

  SetMinutesAction({required this.sportInfo});
}

class SetEventSportNameAction extends SportEventsActions {
  final String sportEventName;

  SetEventSportNameAction({required this.sportEventName});
}

class UpdateTimeOfDaySportEventAction extends SportEventsActions {
  final String scheduleTime;

  UpdateTimeOfDaySportEventAction({required this.scheduleTime});
}

class UpdateDaysOfWeekSportEventAction extends SportEventsActions {
  final int weekDay;

  UpdateDaysOfWeekSportEventAction({required this.weekDay});
}

class UpdateIsFavoriteSportEventsActions extends SportEventsActions {
  bool isFavorite;

  UpdateIsFavoriteSportEventsActions({required this.isFavorite});
}

class UpdateIsCreateRoutineSportEventsActions extends SportEventsActions {
  bool isCreateRoutine;

  UpdateIsCreateRoutineSportEventsActions({required this.isCreateRoutine});
}

class AddSportFavoriteFromFavoriteEvent extends SportEventsActions {
  AddSportFavorite sportFavorite;

  AddSportFavoriteFromFavoriteEvent({required this.sportFavorite});
}

class UpdateSportFromFavoriteTabSportEventsActions extends SportEventsActions {
  AddSportFavorite addSportFavorite;

  UpdateSportFromFavoriteTabSportEventsActions({required this.addSportFavorite});
}

class UpdateSportFromRoutinesTabSportEventsActions extends SportEventsActions {
  SportRoutineCompleted sportRoutineCompleted;

  UpdateSportFromRoutinesTabSportEventsActions({required this.sportRoutineCompleted});
}

class FinishSportEventAction extends SportEventsActions {
  SportEventSimple sportEventSimple;
  Function onFinish;

  FinishSportEventAction({required this.sportEventSimple, required this.onFinish});
}

class FinishSportEventActions extends SportEventsActions {
  Function onFinish;

  FinishSportEventActions({required this.onFinish});
}
class FinishSportRoutineAddSportAction extends SportEventsActions {
  SportRoutineCompleted sportRoutineCompleted;
  Function onFinish;

  FinishSportRoutineAddSportAction({required this.sportRoutineCompleted, required this.onFinish});
}

class FinishSportFavouriteAddSportAction extends SportEventsActions {
  AddSportFavorite sportFavorite;
  Function onFinish;

  FinishSportFavouriteAddSportAction({required this.sportFavorite, required this.onFinish});
}

class FinishSportFavoriteActions extends SportEventsActions {
  Function onFinish;

  FinishSportFavoriteActions({required this.onFinish});
}

class DeleteFavSportSportEventsAction extends SportEventsActions {
  AddSportFavorite sportFavorite;
  Function onFinish;

  DeleteFavSportSportEventsAction({required this.sportFavorite, required this.onFinish});
}