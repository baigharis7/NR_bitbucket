import 'package:json_annotation/json_annotation.dart';

part 'nutrients_info_response.g.dart';

@JsonSerializable(explicitToJson: true)
class NutrientsInfoResponse {
  int v;
  List<NutrientInfoResponse> data;

  NutrientsInfoResponse({required this.v, required this.data});

  factory NutrientsInfoResponse.fromJson(Map<String, dynamic> json) => _$NutrientsInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientsInfoResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class NutrientInfoResponse {
  String officialName;
  String unit; // TODO: Pensar si poner una Sealed Class. Sería un Int entonces.
  String name_es;
  String name_en;
  String? description_es;
  String? description_en;
  String? foods_es;
  String? foods_en;
  String? abbr;

  NutrientInfoResponse({required this.officialName, required this.unit, required this.name_es, required this.name_en, this.description_es, this.description_en, this.foods_es, this.foods_en, this.abbr});

  factory NutrientInfoResponse.fromJson(Map<String, dynamic> json) => _$NutrientInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientInfoResponseToJson(this);
}