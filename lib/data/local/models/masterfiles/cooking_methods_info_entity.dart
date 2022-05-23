import 'package:json_annotation/json_annotation.dart';

part 'cooking_methods_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class CookingMethodsInfoEntity {
  int id;
  int v;
  List<CookingMethodInfoEntity> data;

  CookingMethodsInfoEntity({required this.id, required this.v, required this.data});

  factory CookingMethodsInfoEntity.fromJson(Map<String, dynamic> json) => _$CookingMethodsInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodsInfoEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CookingMethodInfoEntity {
  int id;
  String en;
  String es;

  CookingMethodInfoEntity({required this.id, required this.en, required this.es});

  factory CookingMethodInfoEntity.fromJson(Map<String, dynamic> json) => _$CookingMethodInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodInfoEntityToJson(this);
}