import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../domain/models/favorites/sport/sport_favorite.dart';

class JournalSportState {
  bool isLoading;
  ErrorTypes? onError;
  List<SportEventComplete>? todaySportEvents;
  List<AddSportFavorite>? sportsFavorite;
  List<Map<String, dynamic>>? weeklyData;
  SportsInfoMaster? sportsInfoMaster;
  int? userKcal;
  bool? showCard;
  String? sportFavName;

  JournalSportState({
    required this.isLoading,
    this.onError,
    this.todaySportEvents,
    this.sportsFavorite,
    this.weeklyData,
    this.sportsInfoMaster,
    this.userKcal,
    this.showCard,
    this.sportFavName,
  });

  JournalSportState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<SportEventComplete>? todaySportEvents,
    List<AddSportFavorite>? sportsFavorite,
    List<Map<String, dynamic>>? weeklyData,
    SportsInfoMaster? sportsInfoMaster,
    int? userKcal,
    bool? showCard,
    String? sportFavName,
  }) {
    return JournalSportState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      todaySportEvents: todaySportEvents ?? this.todaySportEvents,
      sportsFavorite: sportsFavorite ?? this.sportsFavorite,
      weeklyData: weeklyData ?? this.weeklyData,
      sportsInfoMaster: sportsInfoMaster ?? this.sportsInfoMaster,
      userKcal: userKcal ?? this.userKcal,
      showCard: showCard ?? this.showCard,
      sportFavName: sportFavName ?? this.sportFavName,
    );
  }

}
