part of 'update_sport_bloc.dart';

@immutable
abstract class UpdateSportEvent {}

class InitializationUpdateSportEvent extends UpdateSportEvent {}

class GetSportFromArgumentUpdateSportEvent extends UpdateSportEvent {
  AddSportFavorite sport;

  GetSportFromArgumentUpdateSportEvent({required this.sport});
}

class UpdateSportItemUpdateSportEvent extends UpdateSportEvent {
  final AddSportFavInfo sportInfo;

  UpdateSportItemUpdateSportEvent({required this.sportInfo});
}

class UpdateSportNameUpdateSportEvent extends UpdateSportEvent {
  final String name;

  UpdateSportNameUpdateSportEvent({required this.name});
}

class UpdateSportScheduleTimeUpdateSportEvent extends UpdateSportEvent {
  final String scheduleTime;

  UpdateSportScheduleTimeUpdateSportEvent({required this.scheduleTime});
}

class UpdateSportDayOfWeekUpdateSportEvent extends UpdateSportEvent {
  final int dayOfWeek;

  UpdateSportDayOfWeekUpdateSportEvent({required this.dayOfWeek});
}

class RemoveSportItemUpdateSportEvent extends UpdateSportEvent {
  final AddSportFavInfo sportInfo;
  final Function isGoBack;

  RemoveSportItemUpdateSportEvent({required this.sportInfo, required this.isGoBack});
}

class UpdateSportItemMinutesUpdateSportEvent extends UpdateSportEvent {
  final AddSportFavInfo sportInfo;

  UpdateSportItemMinutesUpdateSportEvent({required this.sportInfo});
}

class UpdateSportItemIntensityUpdateSportEvent extends UpdateSportEvent {
  final AddSportFavInfo sportInfo;

  UpdateSportItemIntensityUpdateSportEvent({required this.sportInfo});
}

class SaveUpdateSportUpdateSportEvent extends UpdateSportEvent {
  final Function onFinish;

  SaveUpdateSportUpdateSportEvent({required this.onFinish});
}

class UpdateIsFavoriteUpdateSportEvent extends UpdateSportEvent {
  final bool isFavorite;

  UpdateIsFavoriteUpdateSportEvent({required this.isFavorite});
}

class UpdateIsRoutineUpdateSportEvent extends UpdateSportEvent {
  final bool isRoutine;

  UpdateIsRoutineUpdateSportEvent({required this.isRoutine});
}

class SaveUpdateSportFavoriteUpdateSportEvent extends UpdateSportEvent {
  final Function onFinish;

  SaveUpdateSportFavoriteUpdateSportEvent({required this.onFinish});
}

class SaveUpdateSportRoutineUpdateSportEvent extends UpdateSportEvent {
  final Function onFinish;

  SaveUpdateSportRoutineUpdateSportEvent({required this.onFinish});
}