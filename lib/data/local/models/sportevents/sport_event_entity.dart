import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'sport_event_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.sportEventEntity)
class SportEventEntity extends HiveObject {
  static const boxName = 'sport_events';

  @HiveField(0) String userId;
  @HiveField(1) int eventDate;
  @HiveField(2) String? comment;
  @HiveField(3) List<SportEventInfoEntity>? info;
  @HiveField(4) int? eventKcals;

  SportEventEntity({
    required this.userId,
    required this.eventDate,
    required this.comment,
    required this.info,
    this.eventKcals,
  });

  factory SportEventEntity.fromJson(Map<String, dynamic> json) => _$SportEventEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.sportEventInfoEntity)
class SportEventInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) int intensity;
  @HiveField(2) int minutes;
  @HiveField(3) int timeStart;
  @HiveField(4) int kcal;
  @HiveField(5) String? name_en;
  @HiveField(6) String? name_es;

  SportEventInfoEntity({
    required this.id,
    required this.intensity,
    required this.minutes,
    required this.timeStart,
    required this.kcal,
    this.name_en,
    this.name_es,
  });

  factory SportEventInfoEntity.fromJson(Map<String, dynamic> json) => _$SportEventInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventInfoEntityToJson(this);
}