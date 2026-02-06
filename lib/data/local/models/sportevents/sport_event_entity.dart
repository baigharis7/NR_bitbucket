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
  @HiveField(3) String? sportName;
  @HiveField(4) List<SportEventInfoEntity>? info;
  @HiveField(5) int? eventKcals;
  @HiveField(6) int eventId;
  @HiveField(7) String? source; // 'manual', 'apple_health', 'health_connect'

  SportEventEntity({
    required this.userId,
    required this.eventDate,
    this.comment,
    this.sportName,
    required this.info,
    this.eventKcals,
    required this.eventId,
    this.source,
  });

  factory SportEventEntity.fromJson(Map<String, dynamic> json) => _$SportEventEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.sportEventInfoEntity)
class SportEventInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) int? intensity;
  @HiveField(2) int minutes;
  @HiveField(3) int? timeStart;
  @HiveField(4) int? kcal;
  @HiveField(5) String? name_en;
  @HiveField(6) String? name_es;
  @HiveField(7) double? distance; // in meters
  @HiveField(8) int? avgHeartRate; // in bpm

  SportEventInfoEntity({
    required this.id,
    this.intensity,
    required this.minutes,
    this.timeStart,
    this.kcal,
    this.name_en,
    this.name_es,
    this.distance,
    this.avgHeartRate,
  });

  factory SportEventInfoEntity.fromJson(Map<String, dynamic> json) => _$SportEventInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventInfoEntityToJson(this);
}