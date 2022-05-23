import 'package:json_annotation/json_annotation.dart';

part 'nutrients_info_master.g.dart';

@JsonSerializable(explicitToJson: true)
class NutrientsInfoMaster {
  List<NutrientInfoMaster> nutrientsInfo;

  NutrientsInfoMaster({required this.nutrientsInfo});

  factory NutrientsInfoMaster.fromJson(Map<String, dynamic> json) => _$NutrientsInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientsInfoMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class NutrientInfoMaster {
  String officialName;
  String unit;
  String en;
  String es;

  NutrientInfoMaster({required this.officialName, required this.unit, required this.en, required this.es});

  factory NutrientInfoMaster.fromJson(Map<String, dynamic> json) => _$NutrientInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientInfoMasterToJson(this);
}