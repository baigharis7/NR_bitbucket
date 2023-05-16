import 'package:json_annotation/json_annotation.dart';

part 'cooking_methods_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CookingMethodsResponse {
  int v;
  List<CookingMethodGroupResponse> data;

  CookingMethodsResponse({required this.v, required this.data});

  factory CookingMethodsResponse.fromJson(Map<String, dynamic> json) => _$CookingMethodsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CookingMethodGroupResponse {
  String g;
  List<int> m;

  CookingMethodGroupResponse({required this.g, required this.m});

  factory CookingMethodGroupResponse.fromJson(Map<String, dynamic> json) => _$CookingMethodGroupResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodGroupResponseToJson(this);
}