import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'sport_favorite_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.addSportFavoriteEntity)
class SportFavoriteEntity extends HiveObject {
  static const boxName = 'sport_favorite';

  @HiveField(0) String userId;
  @HiveField(1) int eventDate;
  @HiveField(2) String? title;
  @HiveField(3) String? comment;
  @HiveField(4) List<SportFavoriteInfoEntity>? info;
  @HiveField(5) int? eventId;
  @HiveField(6) String? scheduleTime;
  @HiveField(7) List<int>? daysOfWeek;
  @HiveField(8) bool? isFavorite;
  @HiveField(9) bool? isCreateRoutine;
  @HiveField(10) String? timeZone;

  SportFavoriteEntity({
    required this.userId,
    required this.eventDate,
    required this.title,
    required this.comment,
    required this.info,
    this.eventId,
    this.scheduleTime,
    this.daysOfWeek,
    this.isFavorite,
    this.isCreateRoutine,
    this.timeZone,
  });

  factory SportFavoriteEntity.fromJson(Map<String, dynamic> json) => _$SportFavoriteEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SportFavoriteEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.addSportFavoriteInfoEntity)
class SportFavoriteInfoEntity {
  @HiveField(0) int? id;
  @HiveField(1) int? intensity;
  @HiveField(2) int? minutes;
  @HiveField(3) int? timeStart;
  @HiveField(4) String? name_en;
  @HiveField(5) String? name_es;

  SportFavoriteInfoEntity({
    required this.id,
    required this.intensity,
    required this.minutes,
    required this.timeStart,
    required this.name_en,
    required this.name_es,
  });

  factory SportFavoriteInfoEntity.fromJson(Map<String, dynamic> json) => _$SportFavoriteInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SportFavoriteInfoEntityToJson(this);
}