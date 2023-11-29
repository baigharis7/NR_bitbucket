part of 'liquid_summary_detail_bloc.dart';

// @immutable
// abstract class LiquidSummaryDetailState {}

class LiquidSummaryDetailState {
  bool isLoading;
  List<WaterEventMaster>? waterEvents;

  LiquidSummaryDetailState({required this.isLoading, this.waterEvents});

  LiquidSummaryDetailState copyWith(
      {required bool isLoading, List<WaterEventMaster>? waterEvents}) {
    return LiquidSummaryDetailState(
      isLoading: isLoading,
      waterEvents: waterEvents ?? this.waterEvents,
    );
  }
}
