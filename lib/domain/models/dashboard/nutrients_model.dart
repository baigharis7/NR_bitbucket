import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';

class NutrientsModel {
  final double quantityConsumed;
  final NutrientInfoMaster nutrientInfoMaster;
  final double fractionToFill;
  final String? unit;
  final num rda;
  final num upperLimit;

  NutrientsModel({
    required this.quantityConsumed,
    required this.nutrientInfoMaster,
    required this.fractionToFill,
    required this.unit,
    required this.rda,
    required this.upperLimit,
  });
}