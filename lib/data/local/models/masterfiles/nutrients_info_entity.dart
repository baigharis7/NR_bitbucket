import 'package:json_annotation/json_annotation.dart';

part 'nutrients_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class NutrientsInfoEntity {
  int id;
  String name;
  String unit; // TODO: Pensar si poner una Sealed Class. Sería un Iny entonces.
  String es;
  String en;

  NutrientsInfoEntity({required this.id, required this.name, required this.unit, required this.es, required this.en});

  factory NutrientsInfoEntity.fromJson(Map<String, dynamic> json) => _$NutrientsInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientsInfoEntityToJson(this);
}