import 'package:json_annotation/json_annotation.dart';

part 'units_info_response.g.dart';

@JsonSerializable(explicitToJson: true)
class UnitsInfoResponse {
  int v;
  List<UnitInfoResponse> data;

  UnitsInfoResponse({required this.v, required this.data});

  factory UnitsInfoResponse.fromJson(Map<String, dynamic> json) => _$UnitsInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UnitsInfoResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UnitInfoResponse {
  int id;
  String en;
  String es;
  String? enPlural;
  String? esPlural;

  UnitInfoResponse({required this.id, required this.en, required this.es, this.enPlural, this.esPlural});

  factory UnitInfoResponse.fromJson(Map<String, dynamic> json) => _$UnitInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UnitInfoResponseToJson(this);

}
