part of 'macro_nutrients_detail_bloc.dart';

@immutable
abstract class MacroNutrientsDetailEvent {}

class LoadMacroNutrientsEventAction extends MacroNutrientsDetailEvent {
  final List<NutrientsModel>? macronutrientsList;

  LoadMacroNutrientsEventAction({required this.macronutrientsList});
}
