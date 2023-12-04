import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'nutrients_info_master.g.dart';

@JsonSerializable(explicitToJson: true)
class NutrientsInfoMaster {
  List<NutrientInfoMaster> nutrientsInfo;

  NutrientsInfoMaster({required this.nutrientsInfo});

  factory NutrientsInfoMaster.fromJson(Map<String, dynamic> json) => _$NutrientsInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientsInfoMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class NutrientInfoMaster extends Translatable {
  String officialName;
  String unit;
  String en;
  String es;
  String? description_es;
  String? description_en;

  NutrientInfoMaster({required this.officialName, required this.unit, required this.en, required this.es, this.description_es, this.description_en});

  factory NutrientInfoMaster.fromJson(Map<String, dynamic> json) => _$NutrientInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientInfoMasterToJson(this);
}