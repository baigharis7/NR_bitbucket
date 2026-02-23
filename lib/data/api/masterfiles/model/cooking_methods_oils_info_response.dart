import 'package:json_annotation/json_annotation.dart';

part 'cooking_methods_oils_info_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CookingMethodsOilsInfoResponse {
  int v;
  List<CookingMethodOilInfoResponse> data;

  CookingMethodsOilsInfoResponse({required this.v, required this.data});

  factory CookingMethodsOilsInfoResponse.fromJson(Map<String, dynamic> json) => _$CookingMethodsOilsInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodsOilsInfoResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CookingMethodOilInfoResponse {
  int id;
  String name;
  double percentage;

  CookingMethodOilInfoResponse({required this.id, required this.name, required this.percentage});

  factory CookingMethodOilInfoResponse.fromJson(Map<String, dynamic> json) => _$CookingMethodOilInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodOilInfoResponseToJson(this);
}
