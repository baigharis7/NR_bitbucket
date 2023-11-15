import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class AddFavoriteSportState {
  bool isLoading;
  ErrorTypes? onError;
  SportsInfoMaster? sportsInfo;
  List<SportFavorite>? sportsFavorite;
  SportFavorite? sportFavorite;
  String? timeStart;
  bool? isEdit;
  List<SportEventInfo>? sportInfo;
  String? comment;
  String? sportName;
  int? eventId;

  AddFavoriteSportState({
    required this.isLoading,
    this.onError,
    this.sportsInfo,
    this.sportsFavorite,
    this.sportFavorite,
    this.timeStart,
    this.isEdit,
    this.sportInfo,
    this.comment,
    this.sportName,
    this.eventId,
  });

  AddFavoriteSportState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    SportsInfoMaster? sportsInfo,
    List<SportFavorite>? sportsFavorite,
    SportFavorite? sportFavorite,
    String? timeStart,
    bool? isEdit,
    List<SportEventInfo>? sportInfo,
    String? comment,
    String? sportName,
    int? eventId,
  }) {
    return AddFavoriteSportState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      sportsFavorite: sportsFavorite ?? this.sportsFavorite,
      sportFavorite: sportFavorite ?? this.sportFavorite,
      timeStart: timeStart ?? this.timeStart,
      isEdit: isEdit ?? this.isEdit,
      sportInfo: sportInfo ?? this.sportInfo,
      comment: comment ?? this.comment,
      sportName: sportName ?? this.sportName,
      eventId: eventId ?? this.eventId,
    );
  }
}
