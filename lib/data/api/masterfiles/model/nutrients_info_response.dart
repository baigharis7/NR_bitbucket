import 'package:json_annotation/json_annotation.dart';

part 'nutrients_info_response.g.dart';

@JsonSerializable(explicitToJson: true)
class NutrientsInfoResponse {
  String name;
  String unit; // TODO: Pensar si poner una Sealed Class. Sería un Iny entonces.
  String es;
  String en;

  NutrientsInfoResponse({required this.name, required this.unit, required this.es, required this.en});

  factory NutrientsInfoResponse.fromJson(Map<String, dynamic> json) => _$NutrientsInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientsInfoResponseToJson(this);
}