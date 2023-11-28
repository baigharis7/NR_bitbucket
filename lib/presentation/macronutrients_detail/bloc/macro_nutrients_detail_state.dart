part of 'macro_nutrients_detail_bloc.dart';


class MacroNutrientsDetailState {
  bool isLoading;
  List<NutrientsModel>? macronutrients;

  MacroNutrientsDetailState({required this.isLoading, this.macronutrients});

  MacroNutrientsDetailState copyWith({
    required isLoading,
    List<NutrientsModel>? macronutrients,
  }) {
    return MacroNutrientsDetailState(
      isLoading: isLoading ?? this.isLoading,
      macronutrients: macronutrients ?? this.macronutrients,
    );
  }
}
