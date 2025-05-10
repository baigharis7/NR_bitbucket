import 'package:json_annotation/json_annotation.dart';

part 'oil_types_response.g.dart';

@JsonSerializable(explicitToJson: true)
class OilTypesResponse {
  int v;
  List<OilTypeResponse> data;

  OilTypesResponse({required this.v, required this.data});

  factory OilTypesResponse.fromJson(Map<String, dynamic> json) => _$OilTypesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OilTypesResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OilTypeResponse {
  int id;
  String en;
  String es;

  OilTypeResponse({required this.id, required this.en, required this.es});

  factory OilTypeResponse.fromJson(Map<String, dynamic> json) => _$OilTypeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OilTypeResponseToJson(this);
}