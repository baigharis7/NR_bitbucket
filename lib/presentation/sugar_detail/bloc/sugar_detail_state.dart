part of 'sugar_detail_bloc.dart';

// @immutable
// abstract class SugarDetailState {}

class SugarDetailState {
  bool isLoading;
  SugarAndFiberModel? sugarAndFiberModel;

  SugarDetailState({required this.isLoading, this.sugarAndFiberModel});

  SugarDetailState copyWith({
    required bool isLoading,
    SugarAndFiberModel? sugarAndFiberModel,
  }) {
    return SugarDetailState(
      isLoading: isLoading,
      sugarAndFiberModel: sugarAndFiberModel ?? this.sugarAndFiberModel,
    );
  }
}
