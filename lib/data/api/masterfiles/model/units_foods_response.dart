import 'package:json_annotation/json_annotation.dart';

part 'units_foods_response.g.dart';

@JsonSerializable(explicitToJson: true)
class UnitsFoodsResponse {
  int v;
  List<UnitFoodResponse> data;

  UnitsFoodsResponse({required this.v, required this.data});

  factory UnitsFoodsResponse.fromJson(Map<String, dynamic> json) => _$UnitsFoodsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UnitsFoodsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UnitFoodResponse {
  int id;
  String units;

  UnitFoodResponse({required this.id, required this.units});

  factory UnitFoodResponse.fromJson(Map<String, dynamic> json) => _$UnitFoodResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UnitFoodResponseToJson(this);

}
