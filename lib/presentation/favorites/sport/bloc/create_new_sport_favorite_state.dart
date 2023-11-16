import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../../domain/models/favorites/sport/add_sport_favorite.dart';

class CreateNewSportFavoriteState {
  bool isLoading;
  ErrorTypes? onError;
  SportsInfoMaster? sportsInfo;
  SportFavorite? sportFavorite;
  DateTime? eventDate;
  TimeOfDay? timeStart;
  int? intensity;
  String? favoriteSportName;
  int? sportIntensities;
  int? sportId;
  int? minutes;
  List<SportInfo>? info;

  CreateNewSportFavoriteState({
    required this.isLoading,
    this.onError,
    this.sportsInfo,
    this.sportFavorite,
    this.eventDate,
    this.timeStart,
    this.intensity,
    this.favoriteSportName,
    this.sportIntensities,
    this.sportId,
    this.minutes,
    this.info,
  });

  CreateNewSportFavoriteState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    SportsInfoMaster? sportsInfo,
    SportFavorite? sportFavorite,
    DateTime? eventDate,
    TimeOfDay? timeStart,
    int? intensity,
    String? favoriteSportName,
    int? sportIntensities,
    int? sportId,
    int? minutes,
    List<SportInfo>? info,
  }) {
    return CreateNewSportFavoriteState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      sportFavorite: sportFavorite ?? this.sportFavorite,
      eventDate: eventDate ?? this.eventDate,
      timeStart: timeStart ?? this.timeStart,
      intensity: intensity ?? this.intensity,
      favoriteSportName: favoriteSportName ?? this.favoriteSportName,
      sportIntensities: sportIntensities ?? this.sportIntensities,
      sportId: sportId ?? this.sportId,
      minutes: minutes ?? this.minutes,
      info: info ?? this.info,
    );
  }

}