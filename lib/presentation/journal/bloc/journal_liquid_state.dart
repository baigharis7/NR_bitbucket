import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../domain/models/profile/user_profile_model.dart';

class JournalLiquidState {
  bool isLoading;
  ErrorTypes? onError;
  List<LiquidEventComplete>? todayLiquidEvents;
  List<Map<String, dynamic>>? weeklyData;
  List<WaterEventMaster>? waterEvents;
  int? userKcal;
  int? kcalConsumed;
  bool? showCard;
  UserProfileModel? userProfile;

  JournalLiquidState({
    required this.isLoading,
    this.onError,
    this.todayLiquidEvents,
    this.weeklyData,
    this.waterEvents,
    this.userKcal,
    this.kcalConsumed,
    this.showCard,
    this.userProfile,
  });

  JournalLiquidState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<LiquidEventComplete>? todayLiquidEvents,
    List<Map<String, dynamic>>? weeklyData,
    List<WaterEventMaster>? waterEvents,
    int? userKcal,
    int? kcalConsumed,
    bool? showCard,
    UserProfileModel? userProfile,
  }) {
    return JournalLiquidState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      todayLiquidEvents: todayLiquidEvents ?? this.todayLiquidEvents,
      weeklyData: weeklyData ?? this.weeklyData,
      waterEvents: waterEvents ?? this.waterEvents,
      userKcal: userKcal ?? this.userKcal,
      kcalConsumed: kcalConsumed ?? this.kcalConsumed,
      showCard: showCard ?? this.showCard,
      userProfile: userProfile ?? this.userProfile,
    );
  }

}