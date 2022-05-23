import 'package:json_annotation/json_annotation.dart';

part 'cooking_methods_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class CookingMethodsEntity {
  int id;
  int v;
  List<CookingMethodGroupEntity> data;

  CookingMethodsEntity({required this.id, required this.v, required this.data});

  factory CookingMethodsEntity.fromJson(Map<String, dynamic> json) => _$CookingMethodsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodsEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CookingMethodGroupEntity {
  String g;
  List<int> m;

  CookingMethodGroupEntity({required this.g, required this.m});

  factory CookingMethodGroupEntity.fromJson(Map<String, dynamic> json) => _$CookingMethodGroupEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodGroupEntityToJson(this);
}