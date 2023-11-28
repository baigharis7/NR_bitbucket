part of 'energy_balance_detail_bloc.dart';

@immutable
abstract class EnergyBalanceDetailEvent {}

class LoadEnergyBalanceEventAction extends EnergyBalanceDetailEvent {
  final EnergyModel? energyModel;

  LoadEnergyBalanceEventAction({required this.energyModel});
}
