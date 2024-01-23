part of 'liquid_summary_detail_bloc.dart';

// @immutable
// abstract class LiquidSummaryDetailState {}

class LiquidSummaryDetailState {
  bool isLoading;
  List<WaterEventMaster>? waterEvents;
  List<LiquidEventComplete>? todayLiquidEvents;

  LiquidSummaryDetailState({
    required this.isLoading,
    this.waterEvents,
    this.todayLiquidEvents,
  });

  LiquidSummaryDetailState copyWith({
    required bool isLoading,
    List<WaterEventMaster>? waterEvents,
    List<LiquidEventComplete>? todayLiquidEvents,
  }) {
    return LiquidSummaryDetailState(
      isLoading: isLoading,
      waterEvents: waterEvents ?? this.waterEvents,
      todayLiquidEvents: todayLiquidEvents ?? this.todayLiquidEvents,
    );
  }
}
