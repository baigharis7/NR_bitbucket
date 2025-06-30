import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../infrastructure/utils/hive_type_ids.dart';

part 'sport_routine_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.sportRoutineEntity)
class SportRoutineEntity extends HiveObject{
  static const boxName = 'sport_routines';
  @HiveField(0) String? userId;
  @HiveField(1) int? eventId;
  @HiveField(2) String? comment;
  @HiveField(3) String? sportName;
  @HiveField(4) String? scheduleTime;
  @HiveField(5) List<SportRoutineInfoEntity>? info;
  @HiveField(6) List<int>? daysOfWeek;
  @HiveField(7) String? timeZone;
  @HiveField(8) int? eventDate;

  SportRoutineEntity({
    this.userId,
    this.eventId,
    this.eventDate,
    this.comment,
    this.sportName,
    this.scheduleTime,
    this.info,
    this.daysOfWeek,
    this.timeZone,
});

  factory SportRoutineEntity.fromJson(Map<String, dynamic> json) => _$SportRoutineEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SportRoutineEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.sportRoutineInfoEntity)
class SportRoutineInfoEntity {
  @HiveField(0) num? id;
  @HiveField(1) String? nameEn;
  @HiveField(2) String? nameEs;
  @HiveField(3) num? timeStart;
  @HiveField(4) num? intensity;
  @HiveField(5) num? minutes;

  SportRoutineInfoEntity({
    this.id,
    this.nameEn,
    this.nameEs,
    this.timeStart,
    this.intensity,
    this.minutes,
});

  factory SportRoutineInfoEntity.fromJson(Map<String, dynamic> json) => _$SportRoutineInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SportRoutineInfoEntityToJson(this);
}