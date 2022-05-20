import 'package:json_annotation/json_annotation.dart';

part 'cooking_methods_info_master.g.dart';

@JsonSerializable(explicitToJson: true)
class CookingMethodsInfoMaster {
  @JsonKey(name: 'cookingMethodsInfo')
  List<CookingMethodInfo>? cookingMethodsInfo;

  CookingMethodsInfoMaster(this.cookingMethodsInfo);

  factory CookingMethodsInfoMaster.fromJson(Map<String, dynamic> json) => _$CookingMethodsInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodsInfoMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CookingMethodInfo {
  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'en')
  String? en;
  @JsonKey(name: 'es')
  String? es;

  CookingMethodInfo(this.id, this.en, this.es);

  factory CookingMethodInfo.fromJson(Map<String, dynamic> json) => _$CookingMethodInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodInfoToJson(this);
}