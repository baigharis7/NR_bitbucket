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
  String name;
  String unit; // TODO: Pensar si poner una Sealed Class. Sería un Iny entonces.
  String es;
  String en;

  NutrientInfoResponse({required this.name, required this.unit, required this.es, required this.en});

  factory NutrientInfoResponse.fromJson(Map<String, dynamic> json) => _$NutrientInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientInfoResponseToJson(this);
}