import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'upload_feces_event_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.uploadFecesEventsEntity)
class UploadFecesEventEntity extends HiveObject {
  @HiveField(0) String userId;
  @HiveField(1) int eventId;
  @HiveField(2) int fecesId;

  UploadFecesEventEntity({required this.userId, required this.eventId, required this.fecesId});

  factory UploadFecesEventEntity.fromJson(Map<String, dynamic> json) => _$UploadFecesEventEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UploadFecesEventEntityToJson(this);
}