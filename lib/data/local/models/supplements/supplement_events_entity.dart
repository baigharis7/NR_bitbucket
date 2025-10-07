import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'supplement_events_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.supplementEventsEntity)
class SupplementEventsEntity extends HiveObject {
  static const boxName = 'supplement_events';
  static const boxNameFavorites = 'supplement_favorites';
  static const boxNameRoutines = 'supplement_routines';

  @HiveField(0) String userId;
  @HiveField(1) int eventId;
  @HiveField(2) int eventDate;
  @HiveField(3) List<SupplementEventsInfoEntity> info;
  @HiveField(4) String? name;
  @HiveField(5) String? scheduleTime;
  @HiveField(6) List<int>? daysOfWeek;
  @HiveField(7) String? timeZone;

  SupplementEventsEntity({required this.userId, required this.eventId, required this.eventDate, required this.info, this.name, this.scheduleTime, this.daysOfWeek, this.timeZone});
  factory SupplementEventsEntity.fromJson(Map<String, dynamic> json) => _$SupplementEventsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SupplementEventsEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.supplementEventsInfoEntity)
class SupplementEventsInfoEntity extends HiveObject {
  @HiveField(0) int id;
  @HiveField(1) String amount;
  @HiveField(2) String unit;

  SupplementEventsInfoEntity({required this.id, required this.amount, required this.unit});

  factory SupplementEventsInfoEntity.fromJson(Map<String, dynamic> json) => _$SupplementEventsInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SupplementEventsInfoEntityToJson(this);
}