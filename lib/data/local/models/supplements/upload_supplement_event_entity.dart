import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'upload_supplement_event_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.uploadSupplementEventEntity)
class UploadSupplementEventEntity extends HiveObject {
  static const boxNameCreatine = 'creatine_events';
  static const boxNameCollagen = 'collagen_events';

  @HiveField(0) String? userId;
  @HiveField(1) int? eventId;
  @HiveField(2) int? value;

  UploadSupplementEventEntity({required this.userId, required this.eventId, required this.value});

  factory UploadSupplementEventEntity.fromJson(Map<String, dynamic> json) => _$UploadSupplementEventEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UploadSupplementEventEntityToJson(this);
}