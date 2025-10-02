import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.supplementEventsEntity)
class SupplementEventsEntity extends HiveObject {
  static const boxNameSupplementEvents = 'supplement_events';

  @HiveField(0) int userId;
  @HiveField(1) int eventId;
  @HiveField(2) int eventDate;
  @HiveField(3) List<SupplementEventsInfoEntity> info;

  SupplementEventsEntity({required this.userId, required this.eventId, required this.eventDate, required this.info});
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.supplementEventsInfoEntity)
class SupplementEventsInfoEntity extends HiveObject {
  @HiveField(0) int id;
  @HiveField(1) String amount;
  @HiveField(2) String unit;

  SupplementEventsInfoEntity({required this.id, required this.amount, required this.unit});
}