part of 'energy_balance_detail_bloc.dart';

// @immutable
// abstract class EnergyBalanceDetailState {}

class EnergyBalanceDetailState {
  bool isLoading;
  EnergyModel? energyModel;
  List<FoodEventComplete>? weeklyFoodEvents;
  List<FoodEventComplete>? weeklyLiquidEvents;
  List<SportEventComplete>? weeklySportEvents;
  UserProfileModel? userProfile;
  double? averageConsumedKcal;
  double? averageSpentKcal;
  List<Map<String, dynamic>>? weeklyEnergyBalance;

  EnergyBalanceDetailState({
    required this.isLoading,
    this.energyModel,
    this.weeklyFoodEvents,
    this.weeklyLiquidEvents,
    this.weeklySportEvents,
    this.userProfile,
    this.averageConsumedKcal,
    this.averageSpentKcal,
    this.weeklyEnergyBalance,
  });

  EnergyBalanceDetailState copyWith({
    required bool isLoading,
    EnergyModel? energyModel,
    List<FoodEventComplete>? weeklyFoodEvents,
    List<FoodEventComplete>? weeklyLiquidEvents,
    List<SportEventComplete>? weeklySportEvents,
    UserProfileModel? userProfile,
    double? averageConsumedKcal,
    double? averageSpentKcal,
    List<Map<String, dynamic>>? weeklyEnergyBalance,
  }) {
    return EnergyBalanceDetailState(
      isLoading: isLoading,
      energyModel: energyModel ?? this.energyModel,
      weeklyFoodEvents: weeklyFoodEvents ?? this.weeklyFoodEvents,
      weeklyLiquidEvents: weeklyLiquidEvents ?? this.weeklyLiquidEvents,
      weeklySportEvents: weeklySportEvents ?? this.weeklySportEvents,
      userProfile: userProfile ?? this.userProfile,
      averageConsumedKcal: averageConsumedKcal ?? this.averageConsumedKcal,
      averageSpentKcal: averageSpentKcal ?? this.averageSpentKcal,
      weeklyEnergyBalance: weeklyEnergyBalance ?? this.weeklyEnergyBalance,
    );
  }
}
