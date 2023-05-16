import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class JournalLiquidState {
  bool isLoading;
  ErrorTypes? onError;
  List<LiquidEventComplete>? todayLiquidEvents;
  List<Map<String, dynamic>>? weeklyData;
  List<WaterEventMaster>? waterEvents;
  int? userKcal;
  int? kcalConsumed;
  bool? showCard;

  JournalLiquidState({
    required this.isLoading,
    this.onError,
    this.todayLiquidEvents,
    this.weeklyData,
    this.waterEvents,
    this.userKcal,
    this.kcalConsumed,
    this.showCard,
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
    );
  }

}