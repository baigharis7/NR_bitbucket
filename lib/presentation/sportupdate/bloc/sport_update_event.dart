part of 'sport_update_bloc.dart';

@immutable
abstract class SportUpdateEvent {}

class InitializeSportUpdateEvent extends SportUpdateEvent {}

class AddSportFromNavSportUpdateEvent extends SportUpdateEvent {
  final SportEventComplete sportEvent;

  AddSportFromNavSportUpdateEvent({required this.sportEvent});
}

class UpdateEventDateSportUpdateEvent extends SportUpdateEvent {
  final DateTime dateTime;

  UpdateEventDateSportUpdateEvent({required this.dateTime});
}

class RemoveSportSportUpdateEvent extends SportUpdateEvent {
  AddSportFavInfo sportInfo;

  RemoveSportSportUpdateEvent({required this.sportInfo});
}

class SetIntensitySportUpdateEvent extends SportUpdateEvent {
  final AddSportFavInfo sportInfo;

  SetIntensitySportUpdateEvent({required this.sportInfo});
}

class SetMinutesSportUpdateEvent extends SportUpdateEvent {
  final AddSportFavInfo sportInfo;

  SetMinutesSportUpdateEvent({required this.sportInfo});
}

class FinishUpdateSportItemSportUpdateEvent extends SportUpdateEvent {
  Function onFinish;

  FinishUpdateSportItemSportUpdateEvent({required this.onFinish});
}