import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../domain/models/favorites/sport/sport_favorite.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';

class SportEventsState {
  bool isLoading;
  ErrorTypes? onError;
  SportsInfoMaster? sportsInfo;
  AddSportFavorite? sportSimpleEvent;
  int? eventDate;
  bool? isEdit;
  List<SportInfo>? info;
  DateTime? calendarDate;

  SportEventsState({
    required this.isLoading,
    this.onError,
    this.sportsInfo,
    this.sportSimpleEvent,
    this.eventDate,
    this.isEdit,
    this.info,
    this.calendarDate,
  });

  SportEventsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    SportsInfoMaster? sportsInfo,
    AddSportFavorite? sportSimpleEvent,
    int? sportId,
    int? minutes,
    int? eventDate,
    bool? isEdit,
    List<SportInfo>? info,
    DateTime? calendarDate,
  }) {
    return SportEventsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      sportSimpleEvent: sportSimpleEvent ?? this.sportSimpleEvent,
      eventDate: eventDate ?? this.eventDate,
      isEdit: isEdit ?? this.isEdit,
      info: info ?? this.info,
      calendarDate: calendarDate ?? this.calendarDate,
    );
  }

}