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
  List<AddSportFavorite>? favSports;
  AddSportFavorite? sportSimpleEvent;
  AddSportFavorite? sportFavoriteEvent;
  bool? isEdit;
  DateTime? calendarDate;
  List<AddSportFavorite>? recentSports;
  int favRecentTab;

  SportEventsState({
    required this.isLoading,
    this.onError,
    this.sportsInfo,
    this.favSports,
    this.sportSimpleEvent,
    this.sportFavoriteEvent,
    this.isEdit,
    this.calendarDate,
    this.recentSports,
    this.favRecentTab = 0,
  });

  SportEventsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    SportsInfoMaster? sportsInfo,
    List<AddSportFavorite>? favSports,
    AddSportFavorite? sportSimpleEvent,
    AddSportFavorite? sportFavoriteEvent,
    bool? isEdit,
    DateTime? calendarDate,
    List<AddSportFavorite>? recentSports,
    int? favRecentTab,
  }) {
    return SportEventsState(
      isLoading: isLoading,
      onError: onError,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      favSports: favSports ?? this.favSports,
      sportSimpleEvent: sportSimpleEvent ?? this.sportSimpleEvent,
      sportFavoriteEvent: sportFavoriteEvent ?? this.sportFavoriteEvent,
      isEdit: isEdit ?? this.isEdit,
      calendarDate: calendarDate ?? this.calendarDate,
      recentSports: recentSports ?? this.recentSports,
      favRecentTab: favRecentTab ?? this.favRecentTab,
    );
  }

}