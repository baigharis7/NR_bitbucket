import 'package:json_annotation/json_annotation.dart';

part 'nutrients_info_master.g.dart';

@JsonSerializable(explicitToJson: true)
class NutrientsInfoMaster {
  List<NutrientInfo> data;

  NutrientsInfoMaster({required this.data});

  factory NutrientsInfoMaster.fromJson(Map<String, dynamic> json) => _$NutrientsInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientsInfoMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class NutrientInfo {
  String officialName;
  String unit;
  String en;
  String es;

  NutrientInfo({required this.officialName, required this.unit, required this.en, required this.es});

  factory NutrientInfo.fromJson(Map<String, dynamic> json) => _$NutrientInfoFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientInfoToJson(this);
}