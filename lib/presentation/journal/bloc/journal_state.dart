import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/explaining_card_ui_model.dart';

import '../../../domain/models/liquidevents/liquid_event_complete.dart';
import '../../../domain/models/profile/user_profile_model.dart';

class JournalState {
  bool isLoading;
  ErrorTypes? onError;
  int? userKcals;
  List<Map<String, dynamic>>? weeklyData;
  List<SportEventComplete>? todaySportEvents;
  List<WaterEventMaster>? waterEvents;
  List<LiquidEventComplete>? todayLiquidEvents;
  bool? showGeneralCard;
  ExplainingCardUIModel? calendarCard;
  ExplainingCardUIModel? foodsCard;
  ExplainingCardUIModel? sportsCard;
  ExplainingCardUIModel? liquidsCard;
  UserProfileModel? userProfile;

  JournalState({
    required this.isLoading,
    required this.onError,
    this.userKcals,
    this.weeklyData,
    this.todaySportEvents,
    this.waterEvents,
    this.todayLiquidEvents,
    this.showGeneralCard,
    this.calendarCard,
    this.foodsCard,
    this.sportsCard,
    this.liquidsCard,
    this.userProfile,
  });

  JournalState copyWith({
    required bool isLoading,
    required ErrorTypes? onError,
    int? userKcals,
    List<Map<String, dynamic>>? weeklyData,
    List<SportEventComplete>? todaySportEvents,
    List<WaterEventMaster>? waterEvents,
    List<LiquidEventComplete>? todayLiquidEvents,
    bool? showGeneralCard,
    ExplainingCardUIModel? calendarCard,
    ExplainingCardUIModel? foodsCard,
    ExplainingCardUIModel? sportsCard,
    ExplainingCardUIModel? liquidsCard,
    UserProfileModel? userProfile,
  }) {
    return JournalState(
      isLoading: isLoading,
      onError: onError,
      userKcals: userKcals ?? this.userKcals,
      weeklyData: weeklyData ?? this.weeklyData,
      todaySportEvents: todaySportEvents ?? this.todaySportEvents,
      waterEvents: waterEvents ?? this.waterEvents,
      todayLiquidEvents: todayLiquidEvents ?? this.todayLiquidEvents,
      showGeneralCard: showGeneralCard ?? this.showGeneralCard,
      calendarCard: calendarCard ?? this.calendarCard,
      foodsCard: foodsCard ?? this.foodsCard,
      sportsCard: sportsCard ?? this.sportsCard,
      liquidsCard: liquidsCard ?? this.liquidsCard,
      userProfile: userProfile ?? this.userProfile,
    );
  }

}