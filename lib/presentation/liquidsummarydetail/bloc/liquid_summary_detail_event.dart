part of 'liquid_summary_detail_bloc.dart';

// @immutable
abstract class LiquidSummaryDetailEvent {}

class LoadLiquidSummaryEventAction extends LiquidSummaryDetailEvent {
  final List<WaterEventMaster>? waterEvents;

  LoadLiquidSummaryEventAction({required this.waterEvents});
}

class FinishWaterEventAction extends LiquidSummaryDetailEvent {
  double qty;
  final Function onFinish;

  FinishWaterEventAction({required this.qty, required this.onFinish});
}
