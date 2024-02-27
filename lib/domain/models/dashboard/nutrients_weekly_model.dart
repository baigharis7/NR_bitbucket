import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';

class NutrientsWeeklyModel {
  final NutrientInfoMaster nutrientInfoMaster;
  final List<Map<String, dynamic>> weeklyData;
  final num? rda;

  NutrientsWeeklyModel({
    required this.nutrientInfoMaster,
    required this.weeklyData,
    this.rda,
  });
}