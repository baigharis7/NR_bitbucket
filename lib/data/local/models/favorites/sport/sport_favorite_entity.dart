import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'sport_favorite_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.sportFavoriteEntity)
class SportFavoriteEntity extends HiveObject {
  static const boxName = 'sport_favorite';

  @HiveField(0) String userId;
  @HiveField(1) int eventDate;
  @HiveField(2) int? id;
  @HiveField(3) String? name_en;
  @HiveField(4) String? name_es;
  @HiveField(5) String? timeStart;
  @HiveField(6) int? intensity;
  @HiveField(7) int? minutes;
  @HiveField(8) String? title;
  @HiveField(9) String? comment;

  SportFavoriteEntity({
    required this.userId,
    required this.eventDate,
    this.id,
    this.name_en,
    this.name_es,
    this.timeStart,
    this.intensity,
    this.minutes,
    this.title,
    this.comment,
  });

  factory SportFavoriteEntity.fromJson(Map<String, dynamic> json) => _$SportFavoriteEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SportFavoriteEntityToJson(this);
}