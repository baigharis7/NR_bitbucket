import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../domain/models/favorites/sport/sport_favorite.dart';

class SportEventsState {
  bool isLoading;
  ErrorTypes? onError;
  SportsInfoMaster? sportsInfo;
  SportEventSimple? sportEventSimple;
  List<SportFavorite>? sportsFavorite;
  DateTime? dateStart;
  TimeOfDay? timeStart;
  int? intensity;
  String? sportName;
  int? sportIntensities;
  int? sportId;
  int? minutes;
  int? eventDate;
  bool? isEdit;
  String? comment;
  String? eventSportName;
  List<SportInfo>? info;

  SportEventsState({
    required this.isLoading,
    this.onError,
    this.sportsInfo,
    this.sportEventSimple,
    this.sportsFavorite,
    this.dateStart,
    this.timeStart,
    this.intensity,
    this.sportName,
    this.sportIntensities,
    this.sportId,
    this.minutes,
    this.eventDate,
    this.isEdit,
    this.comment,
    this.eventSportName,
    this.info,
  });

  SportEventsState copyWith({
    required bool isLoading,
    required ErrorTypes? onError,
    SportsInfoMaster? sportsInfo,
    SportEventSimple? sportEventSimple,
    List<SportFavorite>? sportsFavorite,
    DateTime? dateStart,
    TimeOfDay? timeStart,
    int? intensity,
    String? sportName,
    int? sportIntensities,
    int? sportId,
    int? minutes,
    int? eventDate,
    bool? isEdit,
    String? comment,
    String? eventSportName,
    List<SportInfo>? info,
  }) {
    return SportEventsState(
      isLoading: isLoading,
      onError: onError,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      sportEventSimple: sportEventSimple ?? this.sportEventSimple,
      sportsFavorite: sportsFavorite ?? this.sportsFavorite,
      dateStart: dateStart ?? this.dateStart,
      timeStart: timeStart ?? this.timeStart,
      intensity: intensity ?? this.intensity,
      sportName: sportName ?? this.sportName,
      sportIntensities: sportIntensities ?? this.sportIntensities,
      sportId: sportId ?? this.sportId,
      minutes: minutes ?? this.minutes,
      eventDate: eventDate ?? this.eventDate,
      isEdit: isEdit ?? this.isEdit,
      comment: comment ?? this.comment,
      eventSportName: eventSportName ?? this.eventSportName,
      info: info ?? this.info,
    );
  }

}