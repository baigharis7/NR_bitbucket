import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';

class NutrientsWeeklyModel {
  final NutrientInfoMaster nutrientInfoMaster;
  final List<Map<String, dynamic>> weeklyData;
  final num? rda;
  final num? upperLimit;

  NutrientsWeeklyModel({
    required this.nutrientInfoMaster,
    required this.weeklyData,
    this.rda,
    this.upperLimit,
  });
}