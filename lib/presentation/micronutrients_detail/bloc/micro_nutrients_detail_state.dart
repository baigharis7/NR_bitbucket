part of 'micro_nutrients_detail_bloc.dart';

class MicroNutrientsDetailState {
  bool isLoading;
  List<NutrientsModel>? microNutrients;

  MicroNutrientsDetailState({
    required this.isLoading,
    this.microNutrients,
  });

  MicroNutrientsDetailState copyWith({
    required bool isLoading,
    List<NutrientsModel>? microNutrients,
  }) {
    return MicroNutrientsDetailState(
      isLoading: isLoading,
      microNutrients: microNutrients ?? this.microNutrients,
    );
  }
}

