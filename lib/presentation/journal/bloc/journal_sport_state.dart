import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class JournalSportState {
  bool isLoading;
  ErrorTypes? onError;
  List<SportEventComplete>? todaySportEvents;
  List<Map<String, dynamic>>? weeklyData;
  SportsInfoMaster? sportsInfoMaster;
  int? userKcal;
  bool? showCard;

  JournalSportState({
    required this.isLoading,
    this.onError,
    this.todaySportEvents,
    this.weeklyData,
    this.sportsInfoMaster,
    this.userKcal,
    this.showCard,
  });

  JournalSportState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<SportEventComplete>? todaySportEvents,
    List<Map<String, dynamic>>? weeklyData,
    SportsInfoMaster? sportsInfoMaster,
    int? userKcal,
    bool? showCard,
  }) {
    return JournalSportState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      todaySportEvents: todaySportEvents ?? this.todaySportEvents,
      weeklyData: weeklyData ?? this.weeklyData,
      sportsInfoMaster: sportsInfoMaster ?? this.sportsInfoMaster,
      userKcal: userKcal ?? this.userKcal,
      showCard: showCard ?? this.showCard,
    );
  }

}
