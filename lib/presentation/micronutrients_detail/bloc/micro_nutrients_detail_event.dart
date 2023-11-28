part of 'micro_nutrients_detail_bloc.dart';

abstract class MicroNutrientsDetailEvent {}

class LoadMicroNutrientsDetails extends MicroNutrientsDetailEvent {
  final List<NutrientsModel> micronutrientsList;

  LoadMicroNutrientsDetails({required this.micronutrientsList});
}
