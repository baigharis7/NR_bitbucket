part of 'energy_balance_detail_bloc.dart';

// @immutable
// abstract class EnergyBalanceDetailState {}

class EnergyBalanceDetailState {
  bool isLoading;
  EnergyModel? energyModel;

  EnergyBalanceDetailState({required this.isLoading, this.energyModel});

  EnergyBalanceDetailState copyWith({
    required bool isLoading,
    EnergyModel? energyModel,
  }) {
    return EnergyBalanceDetailState(
      isLoading: isLoading,
      energyModel: energyModel ?? this.energyModel,
    );
  }
}
