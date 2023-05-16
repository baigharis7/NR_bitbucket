import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'water_event_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.waterEventEntity)
class WaterEventEntity extends HiveObject {
  static const boxName = 'water_events';

  @HiveField(0) String? userId;
  @HiveField(1) int? eventDate;
  @HiveField(2) double qty;

  WaterEventEntity(
      this.userId,
      this.eventDate,
      this.qty,
  );

  factory WaterEventEntity.fromJson(Map<String, dynamic> json) => _$WaterEventEntityFromJson(json);
  Map<String, dynamic> toJson() => _$WaterEventEntityToJson(this);
}