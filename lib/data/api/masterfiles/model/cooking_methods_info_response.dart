import 'package:json_annotation/json_annotation.dart';

part 'cooking_methods_info_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CookingMethodsInfoResponse {
  int v;
  List<CookingMethodInfo> data;

  CookingMethodsInfoResponse({required this.v, required this.data});

  factory CookingMethodsInfoResponse.fromJson(Map<String, dynamic> json) => _$CookingMethodsInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodsInfoResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CookingMethodInfo {
  int id;
  String en;
  String es;

  CookingMethodInfo({required this.id, required this.en, required this.es});

  factory CookingMethodInfo.fromJson(Map<String, dynamic> json) => _$CookingMethodInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodInfoToJson(this);
}