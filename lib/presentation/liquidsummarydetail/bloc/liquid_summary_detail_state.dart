part of 'liquid_summary_detail_bloc.dart';

// @immutable
// abstract class LiquidSummaryDetailState {}

class LiquidSummaryDetailState {
  bool isLoading;
  ErrorTypes? onError;
  List<WaterEventMaster>? waterEvents;
  List<LiquidEventComplete>? todayLiquidEvents;
  UserProfileModel? userProfile;

  LiquidSummaryDetailState({
    required this.isLoading,
    this.onError,
    this.waterEvents,
    this.todayLiquidEvents,
    this.userProfile,
  });

  LiquidSummaryDetailState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<WaterEventMaster>? waterEvents,
    List<LiquidEventComplete>? todayLiquidEvents,
    UserProfileModel? userProfile,
  }) {
    return LiquidSummaryDetailState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      waterEvents: waterEvents ?? this.waterEvents,
      todayLiquidEvents: todayLiquidEvents ?? this.todayLiquidEvents,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}
