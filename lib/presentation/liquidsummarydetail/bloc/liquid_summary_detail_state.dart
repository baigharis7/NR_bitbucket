part of 'liquid_summary_detail_bloc.dart';

// @immutable
// abstract class LiquidSummaryDetailState {}

class LiquidSummaryDetailState {
  bool isLoading;

  LiquidSummaryDetailState({required this.isLoading});

  LiquidSummaryDetailState copyWith({required bool isLoading}) {
    return LiquidSummaryDetailState(
        isLoading: isLoading,
    );
  }
}
