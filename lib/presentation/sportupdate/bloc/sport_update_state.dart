part of 'sport_update_bloc.dart';

// @immutable
// abstract class SportUpdateState {}

class SportUpdateState {
  bool isLoading;
  ErrorTypes? onError;
  SportsInfoMaster? sportsInfo;
  AddSportFavorite? sportSimpleEvent;

  SportUpdateState({
    required this.isLoading,
    this.onError,
    this.sportsInfo,
    this.sportSimpleEvent,
  });

  SportUpdateState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    SportsInfoMaster? sportsInfo,
    AddSportFavorite? sportSimpleEvent,
  }) {
    return SportUpdateState(
      isLoading: isLoading,
      onError: onError,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      sportSimpleEvent: sportSimpleEvent ?? this.sportSimpleEvent,
    );
  }
}
