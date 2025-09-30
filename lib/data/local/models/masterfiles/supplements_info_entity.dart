import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

// part 'supplements_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.supplementsInfoEntity)
class SupplementsInfoEntity {
  @HiveField(0) int v;
  @HiveField(1) List<SupplementInfoEntity> data;
  SupplementsInfoEntity({required this.v, required this.data});
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.supplementInfoEntity)
class SupplementInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) String es;
  @HiveField(2) String en;
  @HiveField(3) String unit;

  SupplementInfoEntity({required this.id, required this.es, required this.en, required this.unit});
}