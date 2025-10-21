part of 'update_sport_bloc.dart';

// @immutable
// abstract class UpdateSportState {}

class UpdateSportState {
  bool isLoading;
  ErrorTypes? onError;
  SportsInfoMaster? sportsInfo;
  AddSportFavorite? sportSimple;

  UpdateSportState({
    required this.isLoading,
    this.onError,
    this.sportsInfo,
    this.sportSimple,
  });

  UpdateSportState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    SportsInfoMaster? sportsInfo,
    AddSportFavorite? sportSimple,
  }) {
    return UpdateSportState(
      isLoading: isLoading,
      onError: onError,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      sportSimple: sportSimple ?? this.sportSimple,
    );
  }
}
