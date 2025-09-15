part of 'sport_items_bloc.dart';

// @immutable
// abstract class SportItemsState {}

class SportItemsState {
  bool isLoading;
  ErrorTypes? onError;
  SportsInfoMaster? sportsInfo;
  DateTime? dateTime;
  List<SportEventComplete>? sportEvents;

  SportItemsState({
    required this.isLoading,
    this.onError,
    this.sportsInfo,
    this.dateTime,
    this.sportEvents,
  });

  SportItemsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    SportsInfoMaster? sportsInfo,
    DateTime? dateTime,
    List<SportEventComplete>? sportEvents,
  }) {
    return SportItemsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      dateTime: dateTime ?? this.dateTime,
      sportEvents: sportEvents ?? this.sportEvents,
    );
  }
}
