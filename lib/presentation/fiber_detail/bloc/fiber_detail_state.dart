part of 'fiber_detail_bloc.dart';

// @immutable
// abstract class FiberDetailState {}

class FiberDetailState {
  bool isLoading;
  SugarAndFiberModel? sugarAndFiberModel;

  FiberDetailState({required this.isLoading, this.sugarAndFiberModel});

  FiberDetailState copyWith({
    required bool isLoading,
    SugarAndFiberModel? sugarAndFiberModel,
  }) {
    return FiberDetailState(
      isLoading: isLoading,
      sugarAndFiberModel: sugarAndFiberModel ?? this.sugarAndFiberModel,
    );
  }
}
