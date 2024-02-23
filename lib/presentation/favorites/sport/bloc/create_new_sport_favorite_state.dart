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
  int? eventDate;
  String? favoriteSportName;
  List<AddSportFavInfo>? info;
  String? comment;
  bool? isCreateRoutine;
  bool? isEdit;
  TimeOfDay? routineHour;
  DateTime? routineDate;

  CreateNewSportFavoriteState({
    required this.isLoading,
    this.onError,
    this.sportsInfo,
    this.eventDate,
    this.favoriteSportName,
    this.info,
    this.comment,
    this.isCreateRoutine,
    this.isEdit,
    this.routineHour,
    this.routineDate,
  });

  CreateNewSportFavoriteState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    SportsInfoMaster? sportsInfo,
    int? eventDate,
    String? favoriteSportName,
    List<AddSportFavInfo>? info,
    String? comment,
    bool? isCreateRoutine,
    bool? isEdit,
    TimeOfDay? routineHour,
    DateTime? routineDate,
  }) {
    return CreateNewSportFavoriteState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      eventDate: eventDate ?? this.eventDate,
      favoriteSportName: favoriteSportName ?? this.favoriteSportName,
      info: info ?? this.info,
      comment: comment ?? this.comment,
      isCreateRoutine: isCreateRoutine ?? this.isCreateRoutine,
      isEdit: isEdit ?? this.isEdit,
      routineHour: routineHour ?? this.routineHour,
      routineDate: routineDate ?? this.routineDate,
    );
  }

}