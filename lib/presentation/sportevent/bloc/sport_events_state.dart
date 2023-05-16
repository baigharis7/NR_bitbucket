import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class SportEventsState {
  bool isLoading;
  ErrorTypes? onError;
  SportsInfoMaster? sportsInfo;
  SportEventSimple? sportEventSimple;
  DateTime? dateStart;
  TimeOfDay? timeStart;
  int? intensity;
  String? sportName;
  int? sportIntensities;
  int? sportId;
  int? minutes;
  int? eventDate;
  bool? isEdit;

  SportEventsState({
    required this.isLoading,
    this.onError,
    this.sportsInfo,
    this.sportEventSimple,
    this.dateStart,
    this.timeStart,
    this.intensity,
    this.sportName,
    this.sportIntensities,
    this.sportId,
    this.minutes,
    this.eventDate,
    this.isEdit,
  });

  SportEventsState copyWith({
    required bool isLoading,
    required ErrorTypes? onError,
    SportsInfoMaster? sportsInfo,
    SportEventSimple? sportEventSimple,
    DateTime? dateStart,
    TimeOfDay? timeStart,
    int? intensity,
    String? sportName,
    int? sportIntensities,
    int? sportId,
    int? minutes,
    int? eventDate,
    bool? isEdit,
  }) {
    return SportEventsState(
      isLoading: isLoading,
      onError: onError,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      sportEventSimple: sportEventSimple ?? this.sportEventSimple,
      dateStart: dateStart ?? this.dateStart,
      timeStart: timeStart ?? this.timeStart,
      intensity: intensity ?? this.intensity,
      sportName: sportName ?? this.sportName,
      sportIntensities: sportIntensities ?? this.sportIntensities,
      sportId: sportId ?? this.sportId,
      minutes: minutes ?? this.minutes,
      eventDate: eventDate ?? this.eventDate,
      isEdit: isEdit ?? this.isEdit,
    );
  }

}