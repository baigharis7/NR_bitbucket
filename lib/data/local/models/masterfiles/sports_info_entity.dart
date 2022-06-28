import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'sports_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.sportsInfoEntity)
class SportsInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<SportInfoEntity> data;

  SportsInfoEntity({required this.id, required this.v, required this.data});

  factory SportsInfoEntity.fromJson(Map<String, dynamic> json) => _$SportsInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SportsInfoEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.sportInfoEntity)
class SportInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) String en;
  @HiveField(2) String es;
  @HiveField(3) int mets;

  SportInfoEntity({required this.id, required this.en, required this.es, required this.mets});

  factory SportInfoEntity.fromJson(Map<String, dynamic> json) => _$SportInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SportInfoEntityToJson(this);

}

